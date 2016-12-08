class UsageCacheRefreshJob < ActiveJob::Base
  queue_as :usage_cache

  def perform(organization=nil)
    if organization
      warm_cache(organization)
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
    ud = UsageDecorator.new(organization, Time.now.year, Time.now.month)
    ud.usage_data(force: true)
  end

  def organizations
    Organization.active.shuffle
  end

end
