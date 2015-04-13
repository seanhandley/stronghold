module Billing
  require_relative 'billing/instances'
  require_relative 'billing/volumes'

  def self.sync!
    ActiveRecord::Base.transaction do
      from = Billing::Sync.last.started_at
      to   = Time.now
      sync = Billing::Sync.create started_at: Time.now
      Billing::Instances.sync!(from, to, sync)
      Billing::Volumes.sync!(from, to, sync)
      #Billing::FloatingIps.sync!(from, to, sync)
      Billing::IpQuotas.sync!(sync)
      Billing::ExternalGateways.sync!(from, to, sync)
      Billing::Images.sync!(from, to, sync)
      Billing::StorageObjects.sync!(sync)
      sync.update_attributes(completed_at: Time.now)
      #raise ActiveRecord::Rollback
    end
  end

  def self.fetch_samples(tenant_id, measurement, from, to)
    timestamp_format = "%Y-%m-%dT%H:%M:%S"
    options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.utc.strftime(timestamp_format)},
               {'field' => 'timestamp', 'op' => 'lt', 'value' => to.utc.strftime(timestamp_format)},
               {'field' => 'project_id', 'value' => tenant_id, 'op' => 'eq'}]
    tenant_samples = Fog::Metering.new(OPENSTACK_ARGS).get_samples(measurement, options).body
    tenant_samples.group_by{|s| s['resource_id']}
  end
end