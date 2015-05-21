require 'open_stack_object'

class AuthorizedController < ApplicationController
  before_filter :current_user, :authenticate_user!, :timeout_session!
  before_filter { Authorization.current_user = current_user }
  before_filter { Authorization.current_user.token = session[:token] }
  around_filter :user_time_zone, :if => :current_user
  before_action :set_locale

  check_authorization

  def current_ability
    @current_ability ||= User::Ability.new(current_user)
  end

  def reauthenticate(password)
    if token = current_user.authenticate(password)
      if token.is_a? String
        session[:created_at] = Time.now.utc
        session[:token]      = token
        return true
      else
        return false
      end
    end
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
      format.json   { javascript_redirect_to support_root_url }
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
      redirect_to sign_in_path('next' => request.fullpath)
      return
    end
    if !current_user.organization.known_to_payment_gateway?
      return if allowed_paths_unactivated.include?(request.fullpath)
      redirect_to activate_path
    elsif !current_user.organization.has_payment_method?
      if !current_user.admin?
        reset_session
        flash.alert = "Payment method has expired. Please inform a user with admin rights."
        redirect_to sign_in_path
      else
        return if request.fullpath == support_manage_cards_path
        redirect_to support_manage_cards_path, alert: "Please add a valid card to continue."
      end
    end
  end

  def allowed_paths_unactivated
    [activate_path, support_cards_path, support_tickets_path,
    support_profile_path, support_usage_path, support_edit_organization_path,
    '/support/api/tickets',
    support_user_path(current_user), support_organization_path(current_user.organization)]
  end

  def timeout_session!
    if session
      session[:created_at] = Time.now.utc unless session[:created_at]

      if (Time.now - session[:created_at]) > SESSION_TIMEOUT.minutes
        session[:user_id] = nil
        redirect_to sign_in_path, notice: t(:signed_out_after_timeout)
      end
    end
  end
end