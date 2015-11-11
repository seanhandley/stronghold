class SessionsController < ApplicationController

  layout 'customer-sign-up'
  before_filter :check_for_user, except: [:destroy]
  
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
            redirect_to URI(params[:next]).path
          else
            redirect_to support_root_path
          end
        else
          Rails.cache.write("up_#{@user.uuid}", password, expires_in: 60.minutes.from_now.to_time.to_i)
          redirect_to new_support_card_path 
        end
        
      else
        flash.now.alert = "Invalid credentials. Please try again."
        Rails.logger.error "Invalid login: #{params_user[:email]}. Token=#{token.inspect}"
        render :new
      end
    else
      flash.now.alert = "Invalid credentials. Please try again."
      render :new
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

end