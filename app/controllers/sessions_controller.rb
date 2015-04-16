class SessionsController < ApplicationController

  layout 'sign-in'
  before_filter :check_for_user, except: [:destroy]
  
  def new
    respond_to do |wants|
      wants.html
    end
  end

  def index
    redirect_to root_path
  end
  
  def create
    @user = User.find_by_email(params[:user][:email])

    if @user and params[:user][:password].present? and (token = @user.authenticate(params[:user][:password])) and token
      session[:token]      = token
      session[:user_id]    = @user.id
      session[:created_at] = Time.zone.now
      if params[:next]
        redirect_to params[:next]
      else
        redirect_to support_root_path
      end
    elsif @user and params[:user][:password].present? and @user.authenticate_local(params[:user][:password]) and !@user.organization.has_payment_method?
      Rails.cache.write("up_#{@user.uuid}", params[:user][:password], expires_in: 60.minutes)
      session[:user_id]    = @user.id
      session[:created_at] = Time.zone.now
      redirect_to new_support_card_path     
    else
      flash.now.alert = "Invalid credentials. Please try again."
      Rails.logger.error "Invalid login: #{params[:user][:email]}. Token=#{token.inspect}"
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