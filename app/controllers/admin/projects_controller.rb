module Admin
  class ProjectsController < AdminBaseController
    include ProjectControllerHelper
    include UserProjectRoleHelper

    def show
      fetch_projects
    end

    private

    def redirect_path
      admin_customer_path(@organization)
    end

    def get_organization
      @organization = Organization.find(params[:customer_id])
    end
  end
end
