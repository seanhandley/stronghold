class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ActionController::InvalidAuthenticityToken do |exception|
    reset_session
    safe_redirect_to sign_in_url
  end

  before_filter :device_cookie

  def javascript_redirect_to(path)
    render js: "window.location.replace('#{path}')"
  end

  def slow_404
    sleep 2 if Rails.env.production?
    raise ActionController::RoutingError.new('Not Found')
  end

  def safe_redirect_to(path, args={})
    respond_to do |format|
      format.js   { javascript_redirect_to path }
      format.json { render :json => [], :status => :unauthorized }
      format.html { redirect_to path, args }
    end
  end

  def sanitize_path(path)
    [URI(path).path, URI(path).query.present? ? URI(path).query : nil].compact.join('?')
  end

  def ajax_response(model, action, success_path, *args)
    if model.send(action, *args)
      javascript_redirect_to success_path
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => model }, status: :unprocessable_entity}
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
    current_user ? current_user.organization : nil
  end
  helper_method :current_organization

  def current_path
    request.get? ? request.fullpath : request.original_fullpath.split('?').first
  end
  helper_method :current_path

  def device_cookie
    args = {value: SecureRandom.urlsafe_base64, expires: 2.years.from_now}
    cookies[:_d] = args unless cookies[:_d]
    @device_cookie ||= cookies[:_d]
  end
  helper_method :device_cookie

  helper Starburst::AnnouncementsHelper

end
