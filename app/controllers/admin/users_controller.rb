module Admin
  class UsersController < AdminBaseController

    before_action :get_organization
    before_action :get_user, only: [:destroy]

    def index
      @users = @organization.users
    end

    def destroy
      @organization_user = OrganizationUser.find_by organization: @organization, user: @user
      if @organization_user
        ajax_response(@organization_user, :destroy, admin_customer_path(@organization))
      else
        respond_to do |format|
          format.js { render :template => "shared/dialog_info", :locals => {:object => @user, message: "User is not a member of this organization" }, :status => :unprocessable_entity }
        end
      end
    end

    private

    def get_user
      @user = @organization.users.find params[:id]
    end

    def get_organization
      @organization = Organization.find params[:customer_id]
    end
  end
end
