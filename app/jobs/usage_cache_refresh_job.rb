class UsageCacheRefreshJob < ActiveJob::Base
  queue_as :usage_cache

  def perform(organization=nil)
    if organization
      warm_cache(organization) unless already_running?(organization)
      return
    end
    
    dispersal_time = 600
    spacing = dispersal_time / Organization.active.count
    organizations.each_with_index do |organization, i|
      x = (spacing * i * 1.1) + 5
      UsageCacheRefreshJob.set(wait: x.seconds).perform_later(organization)
    end
  end

  private

  def warm_cache(organization)
    sleep rand(500..5000) / 1000.0
    ud = UsageDecorator.new(organization_plus_tenants_and_billing_items(organization))
    ud.usage_data(from_date: Time.now.beginning_of_month, to_date: Time.now)
  end

  def already_running?(organization)
    return false unless organization

    usage_cache_refresh_job_count = Sidekiq::Workers.new.select do |process_id, thread_id, work|
      work['payload']['wrapped'] == 'UsageCacheRefreshJob' &&
      work['payload']['args'].first['arguments'].count > 0 &&
      org_id_from_global(work['payload']['args'].first['arguments'].first) == organization.id
    end.count
    usage_cache_refresh_job_count > 1
  end

  def org_id_from_global(global)
    global.values.first.split('/').last.to_i
  end

  def organizations
    Organization.active.shuffle
  end

  def organization_plus_tenants_and_billing_items(organization)
    Organization.where(id: organization.id).includes(
      :tenants => [
        :billing_storage_objects,
        :billing_ip_quotas,
        {
        billing_instances: :instance_states,
        billing_volumes: :volume_states,
        billing_images: :image_states,
        billing_external_gateways: :external_gateway_states,
        billing_ips: :ip_states
      }]
    ).first
  end
end
