class Admin::InvitesController < AdminBaseController

  load_and_authorize_resource param_method: :create_params
  before_filter :fetch_invite, only: [:resend, :destroy]
  before_filter :get_organization

  def update
    @invite.complete!

    @new_invite = Invite.create! email: @invite.email, power_invite: true, organization: @organization, project_ids: []
    ajax_response(@new_invite, :save, admin_customer_path(@organization))
  end

  def destroy
    if @invite.destroy
      javascript_redirect_to admin_customer_path(@organization)
    else
      flash[:error] = "Invite couldn't be deleted"
      javascript_redirect_to admin_customer_path(@organization)
    end
  end

  private

  def get_organization
    @organization = @invite.organization
  end

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
