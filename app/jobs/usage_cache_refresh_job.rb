class UsageCacheRefreshJob < ActiveJob::Base
  queue_as :usage_cache

  def perform(organization)
    ud = UsageDecorator.new(organization)
    ud.usage_data(from_date: Time.now.beginning_of_month, to_date: Time.now)
  end
end
