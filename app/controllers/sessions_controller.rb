class SessionsController < ApplicationController

  layout 'sign-in'
  before_filter :check_for_user, except: [:destroy]
  
  def new
    respond_to do |wants|
      wants.html
    end
  end
  
  def create
    @user = User.find_by_email(params[:user][:email])
    if @user and params[:user][:password].present? and @user.authenticate(params[:user][:password])
      session[:user_id] = @user.id
      session[:created_at] = Time.now
      redirect_to support_root_path
    else
      flash.now.alert = "Invalid credentials. Please try again."
      render :new
    end
  end

  def destroy
    session[:user_id] = nil if session[:user_id]
    respond_to do |wants|
      wants.html { redirect_to sign_in_path, :notice => "You have been signed out." }
    end
  end

  private

  def check_for_user
    raise ActionController::RoutingError.new('Not Found') if current_user
  end

end