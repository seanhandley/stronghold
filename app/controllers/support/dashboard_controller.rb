class Support::DashboardController < SupportBaseController

  skip_authorization_check

  def current_section
    'cloud'
  end
  
  def index
    @instance_count = OpenStack::Instance.all.count
    @object_usage = (Ceph::Usage.kilobytes_for(current_user.organization.primary_tenant.uuid) / 1024.0).gigabytes
    @ips_count = 0
  end

end