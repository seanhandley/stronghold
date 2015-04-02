class LocallyAuthorizedController < ApplicationController
  before_filter :current_user, :authenticate_user!, :timeout_session!

  private

  def redirect_to_root(exception=nil)
    respond_to do |format|
      format.js   { javascript_redirect_to support_root_url }
      format.json   { javascript_redirect_to support_root_url }
      format.html { redirect_to support_root_url, :alert => exception ? exception.message : nil }
    end
  end

  def authenticate_user!
    unless current_user
      redirect_to sign_in_path
      return
    end
    if current_user.organization.paying?
      current_user.token = session[:token] if session[:token] && current_user
    else
      redirect_to new_support_card_path unless allowed_request?
    end
  end

  def allowed_request?
    [support_cards_path, new_support_card_path].include? request.fullpath
  end

  def timeout_session!
    if session
      session[:created_at] = Time.now unless session[:created_at]

      if (Time.now - session[:created_at]) > SESSION_TIMEOUT.minutes
        session[:user_id] = nil
        redirect_to sign_in_path, notice: t(:signed_out_after_timeout)
      end
    end
  end
end