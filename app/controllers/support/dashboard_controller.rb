class Support::DashboardController < SupportBaseController

  skip_authorization_check

  def current_section
    'cloud'
  end
  
  def index
    @instance_count = instance_count
    @object_usage = object_usage
  end

  private

  def instance_count
    Rails.cache.fetch("instance_count_#{current_user.organization.primary_tenant.id}", expires_in: 5.minutes) do
      OpenStack::Instance.all.count
    end  
  end

  def object_usage
    Rails.cache.fetch("object_usage_#{current_user.organization.primary_tenant.id}", expires_in: 5.minutes) do
      ((Ceph::Usage.kilobytes_for(current_user.organization.primary_tenant.uuid) / 1024.0) / 1024.0).round(2)
    end
  end

end