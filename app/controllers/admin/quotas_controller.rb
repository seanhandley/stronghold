class Admin::QuotasController < AdminBaseController

  before_filter :find_organization

  def index
    @organizations = Organization.active
  end

  def edit ; end

  def update
    begin
      attrs = {
        limited_storage: storage_params[:limited_storage] ? true : false,
        quota_limit: quota_params.to_h,
        projects_limit: organization_params[:projects_limit]
      } 
      @organization.update_attributes(attrs)
      redirect_to edit_admin_quota_path(@organization), notice: 'Saved'
    rescue ArgumentError => e
      redirect_to edit_admin_quota_path(@organization), notice: e.message
    end
  end

  private

  def find_organization
    @organization ||= Organization.find(params[:id]) if params[:id]
  end

  def quota_params
    params.require(:quota).permit(:compute => [:instances, :cores, :ram],
      :volume => [:volumes, :snapshots, :gigabytes],
      :network => [:floatingip, :router, :port, :subnet, :network, :security_group, :security_group_rule])
  end

  def storage_params
    params.permit(:limited_storage)
  end

  def organization_params
    params.require(:organization).permit(:projects_limit)
  end

end
