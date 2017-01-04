module Admin
  class UsersController < AdminBaseController

    before_action :get_user, only: [:destroy]
    before_action :get_organization


    def index
      @users = @organization.users
    end

    def destroy
      ajax_response(@user, :destroy, admin_customer_path(@organization))
    end

    private

    def get_user
      @user = User.find params[:id]
    end

    def get_organization
      @organization = Organization.find params[:customer_id]
    end
  end
end
