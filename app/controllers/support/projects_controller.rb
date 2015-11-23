class Support::ProjectsController < SupportBaseController
  include UserTenantRoleHelper

  skip_authorization_check

  before_filter :check_power_user_and_cloud_and_unrestricted
  before_filter :fetch_tenant, only: [:update, :destroy]

  def index
    @tenants = Tenant.where(organization: current_organization).includes(:users)
  end

  def create
    @tenant = current_organization.tenants.create(name: tenant_params[:name])
    if @tenant.save
      @tenant.update(user_tenant_roles_attributes)
      @tenant.update_attributes(quota_set: quota_params.to_h)
      @tenant.enable!
      javascript_redirect_to support_projects_path
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @tenant } }
      end
    end
  end

  def update
    ajax_response(@tenant, :update, support_projects_path, user_tenant_roles_attributes.merge(name: tenant_params[:name], quota_set: quota_params.to_h))
  end

  def destroy
    if @tenant.destroy_unless_primary
      redirect_to support_projects_path
    else
      redirect_to support_projects_path, alert: "Couldn't delete project"
    end
  end

  private

  def fetch_tenant
    @tenant ||= Tenant.find(params[:id])
  end

  def check_power_user_and_cloud_and_unrestricted
    raise ActionController::RoutingError.new('Not Found') unless current_user.power_user? && current_organization.cloud? && !current_organization.limited_storage?
  end

  def tenant_params
    params.require(:tenant).permit(:name, :users => Hash[current_organization.users.map{|u| [u.id.to_s, true]}])
  end

   def quota_params
    params.require(:quota).permit(:compute => [:instances, :cores, :ram],
      :volume => [:volumes, :snapshots, :gigabytes],
      :network => [:floatingip, :router, :port, :subnet, :network, :security_group, :security_group_rule])
  end

end