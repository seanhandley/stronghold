class SessionsController < ApplicationController

  layout 'customer-sign-up'
  before_filter :check_for_user, except: [:destroy]
  before_filter :clear_cookies, only: [:new]

  skip_before_filter :verify_authenticity_token, :only => [:create]
  
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
    @user = User.active.find_by_email(params_user[:email])
    if @user and password.present?
      if token = @user.authenticate(password)
        session[:user_id]    = @user.id
        session[:created_at] = Time.now.utc
        session[:token]      = token if token.is_a? String

        if @user.organization.known_to_payment_gateway?
          if params[:next]
            redirect_to sanitize_path(params[:next])
          else
            redirect_to support_root_path
          end
        else
          Rails.cache.write("up_#{@user.uuid}", password, expires_in: 60.minutes)
          redirect_to new_support_card_path 
        end
        organization.transition_to!(:active) if organization.current_state == 'dormant'
        
      else
        flash.now.alert = "Invalid credentials. Please try again."
        Rails.logger.error "Invalid login: #{params_user[:email]}. Token=#{token.inspect}"
        render :new, status: :unprocessable_entity
      end
    else
      flash.now.alert = "Invalid credentials. Please try again."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    respond_to do |wants|
      wants.html { redirect_to sign_in_path, :notice => "You have been signed out." }
    end
  end

  private

  def check_for_user
    raise ActionController::RoutingError.new('Not Found') if current_user
  end

  def clear_cookies
    request.session_options[:skip] = true
    response.headers["Set-Cookie"] = "_stronghold_session=deleted; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; HttpOnly"
  end
end