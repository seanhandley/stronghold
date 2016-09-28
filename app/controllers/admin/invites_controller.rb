class Admin::InvitesController < AdminBaseController

  load_and_authorize_resource param_method: :create_params
  before_filter :fetch_invite, only: [:resend, :destroy]

  def resend
    organization = Organization.find(params[:id]) if params[:id]

    @new_invite = Invite.create! email: @invite.email, power_invite: true, organization: organization, project_ids: []

    if @new_invite.save!
      redirect_to admin_customer_path(organization)
    else
      flash[:error] = "Invite couldn't be sent"
      javascript_redirect_to admin_customer_path(organization)
    end


    if @invite.expired!
      redirect_to admin_customer_path(organization)
    else
      flash[:error] = "Invite couldn't be sent"
      javascript_redirect_to admin_customer_path(organization)
    end
  end

  def destroy
    if @invite.destroy
      javascript_redirect_to admin_customer_path(organization)
    else
      flash[:error] = "Invite couldn't be deleted"
      javascript_redirect_to admin_customer_path(organization)
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
