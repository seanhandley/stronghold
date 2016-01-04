module Support
  class QuotasController < SupportBaseController

    skip_authorization_check

    before_action :check_power_user_and_cloud

    def index
      @projects = current_organization.projects
    end

    private

    def check_power_user_and_cloud
      raise ActionController::RoutingError.new('Not Found') unless current_user.power_user? && current_organization.cloud?
    end

  end
end
