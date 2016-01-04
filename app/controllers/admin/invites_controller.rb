module Admin
  class InvitesController < AdminBaseController

    before_action :fetch_invite
    before_action :get_organization

    def update
      if @invite.resend!
        flash[:notice] = "Invite was resent"
        javascript_redirect_to admin_customer_path(@organization)
      else
        flash[:error] = "Invite couldn't be sent"
        javascript_redirect_to admin_customer_path(@organization)
      end
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

  end
end
