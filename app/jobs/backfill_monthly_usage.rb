class BackfillMonthlyUsageJob < ActiveJob::Base
  queue_as :default

  def perform(months=1)
    Organization.active.shuffle.each do |organization|
      months.times.each_with_index do |_, i|
        d = Time.now - 1.month
        UsageCacheRefreshJob.perform_now(organization, d.beginning_of_month, d.end_of_month)
      end
    end
  end
end
