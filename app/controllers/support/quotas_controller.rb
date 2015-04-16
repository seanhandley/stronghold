class Support::QuotasController < SupportBaseController

  skip_authorization_check

  before_filter :check_power_user_and_cloud

  def index
    @projects = current_user.organization.tenants
  end

  def update
    
  end

  private

  def check_power_user_and_cloud
    raise ActionController::RoutingError.new('Not Found') unless current_user.power_user? && current_user.organization.cloud?
  end

end