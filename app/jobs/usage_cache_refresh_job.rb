class UsageCacheRefreshJob < ApplicationJob
  SLOW_JOB_THRESHOLD = 30
  queue_as :usage_cache
  queue_as { (self.arguments.first.slow_jobs? ? :slow : :default) if self.arguments.any? }

  def perform(organization=nil)
    if organization
      warm_cache(organization)
      return
    end
    
    dispersal_time = 2 * 3600
    spacing = dispersal_time / Organization.active.count
    organizations.each_with_index do |organization, i|
      if organization.slow_jobs?
        UsageCacheRefreshJob.perform_later(organization)
      else
        x = (spacing * i * 1.1) + 5
        UsageCacheRefreshJob.set(wait: x.seconds).perform_later(organization)
      end
    end
  end

  private

  def warm_cache(organization)
    sleep rand(500..5000) / 1000.0
    start = Time.now
    ud = UsageDecorator.new(organization, Time.now.year, Time.now.month)
    ud.usage_data(force: true)
    organization.update_attributes(slow_jobs: (Time.now - start) > SLOW_JOB_THRESHOLD)
  end

  def organizations
    Organization.active.for_usage_tracking.shuffle
  end

end
