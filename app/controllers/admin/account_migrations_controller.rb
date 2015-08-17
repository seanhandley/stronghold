class Admin::AccountMigrationsController < AdminBaseController
  def index
    @organizations = Organization.all.reject(&:staff?)
  end

  def create
    @organization = Organization.find(create_params[:organization_id])
    if @organization.migrate!
      redirect_to admin_account_migrations_path, notice: 'Migrated successfully'
    else
      redirect_to admin_account_migrations_path, alert: 'Failed to migrate'
    end
  end

  private

  def create_params
    params.permit(:organization_id)
  end
end
