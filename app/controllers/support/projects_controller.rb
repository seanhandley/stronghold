module Support
  class ProjectsController < SupportBaseController
    include ProjectControllerHelper
    include UserProjectRoleHelper
    
    skip_authorization_check
    before_action :check_power_user_and_cloud_and_unrestricted

    def index
    end

    private

    def redirect_path
      support_projects_path
    end

    def check_power_user_and_cloud_and_unrestricted
      raise ActionController::RoutingError.new('Not Found') unless current_user.power_user? && current_organization.cloud? && !current_organization.limited_storage?
    end

    def get_organization
      @organization ||= current_organization
    end
  end
end
