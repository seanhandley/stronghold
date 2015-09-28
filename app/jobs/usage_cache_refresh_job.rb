class UsageCacheRefreshJob < ActiveJob::Base
  queue_as :usage_cache

  def perform(organization=nil)
    return warm_cache(organization) if organization

    Organization.active.each do |organization|
      UsageCacheRefreshJob.perform_later(organization)
    end
  end

  private

  def warm_cache(organization)
    ud = UsageDecorator.new(organization)
    ud.usage_data(from_date: Time.now.beginning_of_month, to_date: Time.now)
  end
end
