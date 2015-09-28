class UsageCacheRefreshJob < ActiveJob::Base
  queue_as :usage_cache

  def perform(organization=nil)
    return warm_cache(organization) if organization

    dispersal_time = 300
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
end
