# This SessionsController class is responsible for creating and destroying sessions.
class SessionsController < ApplicationController
  layout 'customer-sign-up'
  before_action :check_for_user, except: [:destroy]
  before_action :clear_cookies, only: [:new]

  skip_before_action :verify_authenticity_token, :only => [:create], raise: false

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def new
    reset_session
    respond_to do |wants|
      wants.html
    end
  end

  def index
    redirect_to root_path
  end

  def create
    params_user = params[:user]
    password = params_user[:password]
    user = User.active.find_by_email(params_user[:email])
    if user && password.present?
      if token = user.authenticate(password)
        set_session_variables(user, password)
        if current_organization.known_to_payment_gateway?
          redirect_if_known_to_payment
        else
          Rails.cache.write("up_#{user.uuid}", password, expires_in: 60.minutes)
          redirect_to new_support_card_path
        end
        current_organization.transition_to!(:active) if current_organization.current_state == 'dormant'
      else
        alert_invalid_credentials
        Rails.logger.error "Invalid login: #{params_user[:email]}. Token=#{token.inspect}"
      end
    else
      alert_invalid_credentials
    end
  end

  def destroy
    RevokeProjectTokensJob.perform_later(current_user)
    reset_session
    respond_to do |wants|
      wants.html { redirect_to sign_in_path, :notice => "You have been signed out." }
    end
  end

  private

  def set_session_variables(user, pass)
    GetProjectTokensJob.perform_later(user, GIBBERISH_CIPHER.encrypt(pass))
    session[:user_id]         = user.id
    session[:created_at]      = Time.now.utc
    session[:token]           = token if token.is_a? String
    cookies.signed[:user_id]  = user.id
    cookies.signed[:current_organization_id] ||= user.primary_organization.id
    session[:organization_id] = cookies.signed[:current_organization_id]

    log_session_info
  end

  def log_session_info
    Rails.logger.info '*' * 10
    Rails.logger.info session[:user_id]
    Rails.logger.info session[:organization_id]
    Rails.logger.info current_user
    Rails.logger.info current_organization
    Rails.logger.info '*' * 10
  end

  def redirect_if_known_to_payment
    if params[:next]
      redirect_to sanitize_path(params[:next])
    else
      redirect_to support_root_path
    end
  end

  def alert_invalid_credentials
    flash.now.alert = "Invalid credentials. Please try again."
    render :new, status: :unprocessable_entity
  end

  def check_for_user
    raise ActionController::RoutingError.new('Not Found') if current_user
  end

  def clear_cookies
    request.session_options[:skip] = true
    response.headers["Set-Cookie"] = "_stronghold_session=deleted; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly"
  end
end
