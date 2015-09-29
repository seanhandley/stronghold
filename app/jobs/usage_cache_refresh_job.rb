class UsageCacheRefreshJob < ActiveJob::Base
  queue_as :usage_cache

  def perform(organization=nil)
    @organization = organization
    return warm_cache(organization) if @organization && !already_running?
    
    dispersal_time = 600
    spacing = dispersal_time / Organization.active.count
    Organization.active.each_with_index do |organization, i|
      x = (spacing * i) + 30
      UsageCacheRefreshJob.set(wait: x.seconds).perform_later(organization)
    end
  end

  private

  def warm_cache(organization)
    ud = UsageDecorator.new(organization)
    ud.usage_data(from_date: Time.now.beginning_of_month, to_date: Time.now)
  end

  def already_running?
    usage_cache_refresh_job_count = Sidekiq::Workers.new.select do |process_id, thread_id, work|
      work['payload']['wrapped'] == 'UsageCacheRefreshJob' &&
      work['payload']['args'].count > 0 &&
      org_id_from_global(work['payload']['args'].first) == @organization.id
    end.count
    usage_cache_refresh_job_count > 1
  end

  def org_id_from_global(global)
    global["_aj_globalid"].split('/').last.to_i
  end
end
