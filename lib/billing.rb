module Billing
  require_relative 'billing/external_gateways'
  require_relative 'billing/floating_ips'
  require_relative 'billing/images'
  require_relative 'billing/instances'
  require_relative 'billing/storage_objects'
  require_relative 'billing/volumes'

  SECONDS_TO_HOURS = 3600.0

  def self.sync!
    ActiveRecord::Base.transaction do
      from = Billing::Sync.last.started_at
      to   = Time.now
      sync = Billing::Sync.create started_at: Time.now
      Billing::Instances.sync!(from, to, sync)
      Billing::Volumes.sync!(from, to, sync)
      Billing::FloatingIps.sync!(from, to, sync)
      Billing::IpQuotas.sync!(sync)
      Billing::ExternalGateways.sync!(from, to, sync)
      Billing::Images.sync!(from, to, sync)
      Billing::StorageObjects.sync!(sync)
      sync.update_attributes(completed_at: Time.now)
      #raise ActiveRecord::Rollback
    end
  end

  def self.fetch_samples(tenant_id, measurement, from, to)
    tenant_samples = fetch_all_samples(measurement, from, to)[tenant_id]
    tenant_samples ? tenant_samples.group_by{|s| s['resource_id']} : {}
  end

  def self.fetch_all_samples(measurement, from, to)
    key = "ceilometer_samples_#{measurement}_#{from.utc.strftime(timestamp_format)}_#{to.utc.strftime(timestamp_format)}"
    Rails.cache.fetch(key, expires_in: 2.hours) do
      options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.utc.strftime(timestamp_format)},
                 {'field' => 'timestamp', 'op' => 'lt', 'value' => to.utc.strftime(timestamp_format)}]
      tenant_samples = Fog::Metering.new(OPENSTACK_ARGS).get_samples(measurement, options).body
      tenant_samples.group_by{|s| s['project_id']}
    end 
  end

  def self.timestamp_format
    "%Y-%m-%dT%H:%M:%S"
  end

  def self.billing_run!(year, month)
    unless (1..12).to_a.include?(month) && year.to_i.to_s.length == 4
      raise ArgumentError, "Please supply a valid year and month"
    end

    ActiveRecord::Base.transaction do
      Organization.self_service.active.each do |organization|
        # Skip if there's already an invoice for this year/month/org
        next if Billing::Invoice.where(organization: organization, year: year, month: month).any?
        
        invoice = Billing::Invoice.new(organization: organization, year: year, month: month)
        ud = UsageDecorator.new(organization)
        ud.usage_data(from_date: invoice.period_start, to_date: invoice.period_end)
        invoice.update_attributes(sub_total: ud.sub_total, grand_total: ud.grand_total,
                                  discount_percent:  ud.discount_percent, tax_percent: ud.tax_percent)
      end
    end
  end
end