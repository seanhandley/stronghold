class Support::AuditsController < SupportBaseController

  skip_authorization_check

  before_filter :check_power_user

  def index
    @audits = Audit.for_organization_and_user(current_organization, current_user).order('created_at DESC')
    @audits = @audits.page params[:page]
  end

  private

  def check_power_user
    raise ActionController::RoutingError.new('Not Found') unless current_user.power_user?
  end
end
