class Support::DashboardController < SupportBaseController

  skip_authorization_check

  def current_section
    'cloud'
  end
  
  def index
    @instance_count = instance_count
    @object_usage = object_usage
  end

  def regenerate_ceph_credentials
    current_user.refresh_ec2_credentials!
    render json: {success: true, credentials: current_user.ec2_credentials}
  rescue StandardError => e
    Honeybadger.notify(e)
    render json: {success: false, message: e.message}
  end

  private

  def instance_count
    live_servers.select{|s| current_user.organization.tenants.map(&:uuid).include?(['tenant_id'])}.count
  end

  def live_servers
    Rails.cache.fetch("live_servers", expires_in: 5.minutes) do
      Fog::Compute.new(OPENSTACK_ARGS).list_servers_detail(all_tenants: true).body['servers']
    end 
  end

  def object_usage
    Rails.cache.fetch("object_usage_#{current_user.organization.primary_tenant.id}", expires_in: 5.minutes) do
      ((Ceph::Usage.kilobytes_for(current_user.organization.primary_tenant.uuid) / 1024.0) / 1024.0).round(2) rescue 0
    end
  end

end