class Admin::InvitesController < AdminBaseController

  load_and_authorize_resource param_method: :create_params
  before_filter :fetch_invite, only: [:resend, :destroy]

  def resend
    organization = Organization.find(params[:id]) if params[:id]
    Invite.create!(email: @invite.email, power_invite: true, organization: organization, project_ids: [])

    @invite.expired!
    redirect_to admin_customer_path(organization)

    # new_invite = current_organization.invites.create(:email => @invite.email, :role_ids => [], :project_ids => [])
    # ajax_response(new_invite, :save, admin_customer_path(organization))
  end

  def destroy 
    if @invite.destroy
      javascript_redirect_to support_roles_path
    end
  end

  def redirect_path
    support_projects_path
  end

  private

  def fetch_invite
    @invite = Invite.find(params[:id])
  end

  def create_params
    params.require(:invite).permit(:email, :role_ids => [], :project_ids => [])
  end

end
