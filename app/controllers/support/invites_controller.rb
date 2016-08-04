class Support::InvitesController < SupportBaseController

  load_and_authorize_resource param_method: :create_params
  before_filter :fetch_invite, only: [:resend, :destroy]

  def create
    @invite = current_organization.invites.create(create_params)
    ajax_response(@invite, :save, support_roles_path)
  end

  def resend
    organization = Organization.find(params[:id]) if params[:id]
    @invite.expired!

    new_invite = current_organization.invites.create(:email => @invite.email, :role_ids => [], :project_ids => [])
    ajax_response(new_invite, :save, admin_customer_path(organization))
  end

  def destroy
    if @invite.organization.id == current_organization.id
      if @invite.destroy
        javascript_redirect_to support_roles_path
      end
    end
  end

  private

  def fetch_invite
    @invite = Invite.find(params[:id])
  end

  def create_params
    params.require(:invite).permit(:email, :role_ids => [], :project_ids => [])
  end

  def update_params
    params.require(:invite).permit(:email, :role_ids => [], :project_ids => [])
  end

end
