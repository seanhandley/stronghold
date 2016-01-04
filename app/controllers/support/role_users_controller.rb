module Support
  class RoleUsersController < SupportBaseController

    load_and_authorize_resource class_name: 'RoleUser'

    def destroy
      @role_user = RoleUser.where(destroy_params).first
      if @role_user.destroy
        redirect_to support_roles_path(tab: 'roles')
      else
        redirect_to support_roles_path(tab: 'roles'), notice: @role_user.errors.full_messages.join
      end
    end

    def create
      @role_user = RoleUser.new(create_params)
      ajax_response(@role_user, :save, support_roles_path(tab: 'roles'))
    end

    private

    def create_params
      params.require(:role_user).permit(:user_id, :role_id)
    end

    def destroy_params
      params.permit(:user_id, :role_id)
    end
  end
end
