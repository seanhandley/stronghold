module Admin
  class AccountMigrationsController < AdminBaseController

    before_action :get_organization

    def update
      if @organization.migrate!
        redirect_to admin_customer_path(@organization), notice: 'Migrated successfully'
      else
        redirect_to admin_customer_path(@organization), alert: 'Failed to migrate'
      end
    end

    private

    def get_organization
      @organization = Organization.find(params[:id]) if params[:id]
    end

    def create_params
      params.permit(:organization_id)
    end
  end
end
