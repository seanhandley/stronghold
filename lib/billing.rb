module Billing
  require_relative 'billing/instances'
  require_relative 'billing/volumes'

  def self.sync!
    ActiveRecord::Base.transaction do
      started_at = Time.zone.now
      from = Billing::Sync.last.started_at
      to   = Time.zone.now
      Billing::Instances.sync!(from, to)
      Billing::Volumes.sync!(from, to)
      Billing::FloatingIps.sync!(from, to)
      Billing::Sync.create started_at: started_at, completed_at: Time.zone.now
    end
  end

  def self.fetch_samples(tenant_id, measurement, from, to)
    timestamp_format = "%Y-%m-%dT%H:%M:%S"
    options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.strftime(timestamp_format)},
               {'field' => 'timestamp', 'op' => 'lt', 'value' => to.strftime(timestamp_format)},
               {'field' => 'project_id', 'value' => tenant_id, 'op' => 'eq'}]
    tenant_samples = Fog::Metering.new(OPENSTACK_ARGS).get_samples(measurement, options).body
    tenant_samples.group_by{|s| s['resource_id']}
  end
end