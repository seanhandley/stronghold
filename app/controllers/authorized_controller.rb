class AuthorizedController < ApplicationController
  before_filter :current_user, :authenticate_user!, :timeout_session!
  before_filter { Authorization.current_user = current_user }
  around_filter :user_time_zone, :if => :current_user
  before_action :set_locale

  check_authorization

  def current_ability
    @current_ability ||= User::Ability.new(current_user)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to_root
  end

  rescue_from OpenStackObject::InvalidCredentialsError do |exception|
    notify_honeybadger(exception)
    reset_session
    redirect_to_root(exception)
  end

  private

  def redirect_to_root(exception=nil)
    respond_to do |format|
      format.js   { javascript_redirect_to support_root_url }
      format.html { redirect_to support_root_url, :alert => exception ? exception.message : nil }
    end
  end

  def set_locale
    I18n.locale = current_user.present? ? current_user.organization.locale.to_sym : I18n.default_locale
  rescue I18n::InvalidLocale
    I18n.locale = I18n.default_locale
  end

  def user_time_zone(&block)
    Time.use_zone(current_user.organization.time_zone, &block)
  end

  def authenticate_user!
    unless current_user
      redirect_to sign_in_path
    end
    current_user.token = session[:token] if session[:token] && current_user
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