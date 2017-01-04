module Support
  class RolesController < SupportBaseController

    load_and_authorize_resource param_method: :role_params
    
    before_action :find_role, :find_organization

    def current_section
      'roles'
    end

    def index
      @roles = @organization.roles
      @users = @organization.users.page params[:page]
      @open_invites = @organization.invites.select(&:can_register?)
    end

    def update
      renamed = @role.name != role_params[:name]
      if @role.update(role_params)
        respond_to do |format|
          format.js {
            if renamed
              javascript_redirect_to support_roles_path(tab: 'roles')
            else
              head :ok
            end
          }
          format.html
        end
      else
        respond_to do |format|
          format.js {
            if renamed
              render :template => "shared/dialog_errors", :locals => {:object => @role }, status: :unprocessable_entity
            else
              head :unprocessable_entity
            end
          }
          format.html
        end 
      end
    end

    def create
      @role = @organization.roles.create(role_params)
      ajax_response(@role, :save, support_roles_path(tab: 'roles'))
    end

    def destroy
      if @role.destroy
        redirect_to support_roles_path(tab: 'roles'), notice: "Role removed successfully"
      else
        redirect_to support_roles_path(tab: 'roles'), notice: @role.errors.full_messages.join
      end
    end

    private

    def find_role
      @role = Role.find(params[:id]) if params[:id]
    end

    def find_organization
      @organization = current_organization
    end

    def role_params
      params.require(:role).permit(:name, {:permissions => []}).
        merge(params[:role].keys.include?('permissions') ? {} : {permissions: []})
    end
    
  end
end
