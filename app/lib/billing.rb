module Billing
  SECONDS_TO_HOURS = 3600.0
  SYNC_INTERVAL_MINUTES = 30

  def self.sync!(to=nil)
    clear_memoized_samples
    last_sync = Billing::Sync.completed.last
    from = last_sync.period_to || last_sync.started_at
    to = to ? from + to.minutes : Time.now
    sync = Billing::Sync.create(period_from: from, period_to: to, started_at: Time.now)
    Billing.logger.info "Starting sync #{sync.id}. From #{from} to #{to}..."
    sleep 10 # Because it can take a few seconds for events to get off the queue and into Mongo
    Billing.logger.info "Syncing instances usage..."
    Billing::Instances.sync!(from, to, sync)
    Billing.logger.info "Syncing volumes usage..."
    Billing::Volumes.sync!(from, to, sync)
    Billing.logger.info "Syncing IP quotas usage..."
    Billing::IpQuotas.sync!(sync)
    Billing.logger.info "Syncing images usage..."
    Billing::Images.sync!(from, to, sync)
    # Billing.logger.info "Syncing object storage usage..."
    # Billing::StorageObjects.sync!(sync)
    Billing.logger.info "Syncing IP allocations..."
    Billing::Ips.sync!(from, to, sync)
    Billing.logger.info "Syncing load balancers..."
    Billing::LoadBalancers.sync!(from, to, sync)
    Billing.logger.info "Syncing VPN connections..."
    Billing::VpnConnections.sync!(from, to, sync)
    sync.update_attributes(completed_at: Time.now)
    clear_memoized_samples
    Billing.logger.info "Completed sync #{sync.id}. #{sync.summary}"
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

  def self.cached_projects
    Rails.cache.fetch('cached_project_info', expires_in: 5.minutes) do
      Project.includes(:organization).pluck("projects.uuid", "projects.name", "organizations.name").inject({}) do |hash, e|
        hash[e[0]] = {project_name: e[1], organization_name: e[2]}
        hash
      end
    end
  end

  def self.fetch_samples(project_id, measurement, from, to)
    if project = cached_projects[project_id]
      Billing.logger.info "Extracting #{measurement} samples from cache for #{project[:organization_name]} (Project: #{project[:project_name]})..."
    end
    project_samples = fetch_all_samples(measurement, from, to)[project_id]
    project_samples ? project_samples.group_by{|s| s['resource_id']} : {}
  end

  def self.memoized_samples
    @@memoized_samples ||= {}
  end

  def self.clear_memoized_samples
    @@memoized_samples = {}
  end

  def self.fetch_all_samples(measurement, from, to)
    key = "ceilometer_samples_#{measurement}_#{from.utc.strftime(timestamp_format)}_#{to.utc.strftime(timestamp_format)}"
    unless memoized_samples.keys.include?(key)
      memoized_samples[key] = Rails.cache.fetch(key, expires_in: 2.hours) do
        Billing.logger.info "Cache miss. Fetching fresh samples of type #{measurement} from #{from} to #{to}..."
        options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.utc.strftime(timestamp_format)},
                   {'field' => 'timestamp', 'op' => 'lt', 'value' => to.utc.strftime(timestamp_format)}]
        project_samples = OpenStackConnection.metering.get_samples(measurement, options).body
        project_samples.group_by{|s| s['project_id']}
      end
    end
    memoized_samples[key]
  end

  # No caching - use for auditing
  def self.fetch_raw_events_for_instance(instance, from, to)
    options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.utc.strftime(timestamp_format)},
                     {'field' => 'timestamp', 'op' => 'lt', 'value' => to.utc.strftime(timestamp_format)},
                     {'field' => 'project_id', 'op' => 'eq', 'value' => instance.project_id}]

    instance_usage = OpenStackConnection.metering.get_samples('instance', options).body
    grouped_results = instance_usage.group_by{|s| s['resource_id']}
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

    Organization.active.billable.cloud.each do |organization|
      BillingRunOrgJob.perform_later(organization, year, month)
    end
  end
end