module Support
  class OrganizationUserRolesController < SupportBaseController
    include ModelErrorsHelper

    load_and_authorize_resource class_name: 'OrganizationUserRole'

    def destroy
      @organization_user_role = OrganizationUserRole.find_by(destroy_params)
      if @organization_user_role&.destroy
        redirect_to support_roles_path(tab: 'roles')
      else
        redirect_to support_roles_path(tab: 'roles'), notice: model_errors_as_html(@organization_user_role)
      end
    end

    def create
      @organization_user_role = OrganizationUserRole.new(create_params)
      ajax_response(@organization_user_role, :save, support_roles_path(tab: 'roles'))
    end

    private

    def create_params
      params.require(:organization_user_role).permit(:organization_user_id, :role_id)
    end

    def destroy_params
      params.permit(:organization_user_id, :role_id)
    end
  end
end
