module Billing
  require_relative 'billing/images'
  require_relative 'billing/instances'
  require_relative 'billing/storage_objects'
  require_relative 'billing/volumes'

  SECONDS_TO_HOURS = 3600.0

  def self.sync!(to=nil)
    from = Billing::Sync.completed.last.started_at
    to = to ? from + to.minutes : Time.now
    sync = Billing::Sync.create(started_at: (to ? to : Time.now))
    Billing.logger.info "Starting sync #{sync.id}. From #{from} to #{to}..."
    sleep 30 # Because it can take a few seconds for events to get off the queue and into Mongo
    Billing::Instances.sync!(from, to, sync)
    Billing::Volumes.sync!(from, to, sync)
    Billing::IpQuotas.sync!(sync)
    Billing::Images.sync!(from, to, sync)
    Billing::StorageObjects.sync!(sync)
    sync.update_attributes(completed_at: Time.now)
    Billing.logger.info "Completed sync #{sync.id}."
    true
  rescue StandardError => e
    Billing.logger.error "Encountered an error (#{e.message}). Removing sync #{sync.id}..."
    sync.destroy
    raise
  ensure
    sync.destroy unless sync.completed_at
  end

  def self.logger
    if Rails.env.production?
      ::Logger.new("/var/log/rails/stronghold/usage_sync.log")
    else
      Rails.logger
    end
  end

  def self.fetch_samples(tenant_id, measurement, from, to)
    tenant_samples = fetch_all_samples(measurement, from, to)[tenant_id]
    tenant_samples ? tenant_samples.group_by{|s| s['resource_id']} : {}
  end

  def self.fetch_all_samples(measurement, from, to)
    key = "ceilometer_samples_#{measurement}_#{from.utc.strftime(timestamp_format)}_#{to.utc.strftime(timestamp_format)}"
    Billing.logger.error "Fetching samples of type #{measurement} from #{from} to #{to}..."
    Rails.cache.fetch(key, expires_in: 2.hours) do
      options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.utc.strftime(timestamp_format)},
                 {'field' => 'timestamp', 'op' => 'lt', 'value' => to.utc.strftime(timestamp_format)}]
      tenant_samples = OpenStackConnection.metering.get_samples(measurement, options).body
      tenant_samples.group_by{|s| s['project_id']}
    end 
  end

  # No caching - use for auditing
  def self.fetch_raw_events_for_instance(instance, from, to)
    options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.utc.strftime(timestamp_format)},
                     {'field' => 'timestamp', 'op' => 'lt', 'value' => to.utc.strftime(timestamp_format)},
                     {'field' => 'project_id', 'op' => 'eq', 'value' => instance.tenant_id}]

    instance_results = OpenStackConnection.metering.get_samples('instance', options).body
    grouped_results = instance_results.group_by{|s| s['resource_id']}
    instance_events = grouped_results[instance.instance_id]
    return [] unless instance_events
    instance_events.collect{|i| i['resource_metadata']['event_type'] ? [i['resource_metadata']['event_type'], i['recorded_at']] : nil}.compact.reverse
  end

  def self.timestamp_format
    "%Y-%m-%dT%H:%M:%S"
  end

  def self.billing_run!(year, month)
    unless (1..12).to_a.include?(month) && year.to_i.to_s.length == 4
      raise ArgumentError, "Please supply a valid year and month"
    end

    Organization.self_service.active.each do |organization|
      # Skip if there's already an invoice for this year/month/org
      next if Billing::Invoice.where(organization: organization, year: year, month: month).any?
      
      invoice = Billing::Invoice.new(organization: organization, year: year, month: month)
      ud = UsageDecorator.new(organization)
      ud.usage_data(from_date: invoice.period_start, to_date: invoice.period_end)
      invoice.update_attributes(sub_total: ud.sub_total, grand_total: ud.grand_total_plus_tax,
                                discount_percent:  ud.discount_percent, tax_percent: ud.tax_percent)
    end
  end
end