class SupportBaseController < ApplicationController

  before_filter :current_user, :authenticate_user!

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def authenticate_user!
    unless current_user
      redirect_to new_support_session_path
    end
  end
end