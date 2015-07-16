class SetCephQuotaJob < ActiveJob::Base
  queue_as :default

  def perform(organization)
    organization.tenants.collect(&:uuid).each do |tenant_id|
      if organization.limited_storage?
        Ceph::UserQuota.set_limited(tenant_id)
      else
        Ceph::UserQuota.set_unlimited(tenant_id)
      end
    end
  end
end