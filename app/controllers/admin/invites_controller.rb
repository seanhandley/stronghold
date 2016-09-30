class Admin::InvitesController < AdminBaseController

  before_filter :fetch_invite
  before_filter :get_organization

  def update
    @invite.update(update_params)
    ajax_response(@invite, :save, admin_customer_path(@organization))
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

  def update_params
    params.permit(:id, :email, :created_at)
  end

end
