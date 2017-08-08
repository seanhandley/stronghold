class AuthorizedController < ApplicationController
  before_action :current_user, :current_organization, :authenticate_user!, :timeout_session!
  before_action { Authorization.current_user = current_user }
  before_action { Authorization.current_organization = current_organization }
  before_action { Authorization.current_user.token = session[:token] }
  before_action { Authorization.current_organization = current_organization }
  around_action :user_time_zone
  before_action :set_locale

  check_authorization

  def current_ability
    @current_ability ||= User::Ability.new(current_user)
  end

  def reauthenticate(password)
    if token = current_user.authenticate(password)
      session[:created_at] = Time.now.utc
      session[:token]      = token
      return true
    else
      return false
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
    I18n.locale = current_user.present? ? current_organization.locale.to_sym : I18n.default_locale
  rescue I18n::InvalidLocale
    I18n.locale = I18n.default_locale
  end

  def user_time_zone
    if current_organization
      Time.use_zone(current_organization.time_zone) { yield }
    end
  end

  def authenticate_user!
    unless current_user && current_organization
      safe_redirect_to sign_in_path('next' => current_path)
      return
    end
    if !current_organization.known_to_payment_gateway? || current_organization.frozen?
      return if allowed_paths_unactivated.include?(current_path) || is_tickets_path?(current_path)
      if current_organization.frozen?
        safe_redirect_to support_root_path
      else
        safe_redirect_to activate_path
      end
    elsif !current_organization.has_payment_method?
      if !current_user.admin?
        reset_session
        flash.alert = "Payment method has expired. Please inform a user with admin rights."
        safe_redirect_to sign_in_path
      else
        return if current_path == support_manage_cards_path
        safe_redirect_to support_manage_cards_path, alert: "Please add a valid card to continue."
      end
    end
  end

  def allowed_paths_unactivated
    [activate_path, new_support_card_path, support_cards_path, support_root_path,
    support_profile_path, support_usage_path, support_edit_organization_path,
    support_manage_cards_path,
    support_user_path(current_user), support_organization_path(current_organization), support_change_organizations_path]
  end

  def is_tickets_path?(path)
    path = path.split('?')[0] # ignore args
    return true if path.include? '/account/api/tickets'
    return true if path.include? '/account/tickets'
    return false
  end

  def timeout_session!
    if session
      session[:created_at] = Time.now.utc unless session[:created_at]

      if (Time.now.utc - Time.parse(session[:created_at].to_s).utc) > SESSION_TIMEOUT.minutes
        reset_session
        safe_redirect_to sign_in_path('next' => current_path)
      end
    end
  end
end
