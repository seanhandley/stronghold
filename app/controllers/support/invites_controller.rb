module Support
  class InvitesController < SupportBaseController

    load_and_authorize_resource param_method: :create_params

    def create
      if @invite.membership?
        params[:membership] = true
      end
      @invite = current_organization.invites.create(create_params)
      ajax_response(@invite, :save, support_roles_path)
    end

    def destroy
      @invite = Invite.find(params[:id])
      if @invite.organization.id == current_organization.id
        if @invite.destroy
          javascript_redirect_to support_roles_path
        end
      end
    end

    private

    def create_params
      params.require(:invite).permit(:email, :role_ids => [], :project_ids => [], :membership => nil)
    end
  end
end
