class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    reset_session
    redirect_to sign_in_url, alert: "There may be a problem with your browser's data. Please clear cookies and try again."
  end

  before_filter :device_cookie

  def javascript_redirect_to(path)
    render js: "window.location.replace('#{path}')"
  end

  def ajax_response(model, action, success_path, *args)
    if model.send(action, *args)
      javascript_redirect_to success_path
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => model } }
      end
    end
  end

  def current_section; end
  helper_method :current_section

  before_action { Authorization.current_user = nil }

  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
    reset_session unless @current_user
    @current_user
  end
  helper_method :current_user

  def current_organization
    current_user ? current_organization : nil
  end
  helper_method :current_organization

  def device_cookie
    args = {value: SecureRandom.hex, expires: 2.years.from_now}
    cookies[:_d] = args unless cookies[:_d]
    @device_cookie ||= cookies[:_d]
  end
  helper_method :device_cookie

  helper Starburst::AnnouncementsHelper

end
