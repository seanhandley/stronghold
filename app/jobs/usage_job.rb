$usage_job_mutex = Mutex.new

class UsageJob < ApplicationJob
  queue_as :slow

  def perform
    return if $usage_job_mutex.locked?
    $usage_job_mutex.synchronize do
      count = 0
      while(mins_since_sync > Billing::SYNC_INTERVAL_MINUTES) do
        Billing.sync!(Billing::SYNC_INTERVAL_MINUTES)
        count += 1
      end
      UsageCacheRefreshJob.perform_later if count > 0
    end
  end

  private

  def mins_since_sync
    last_sync = Billing::Sync.completed.last
    (Time.now - last_sync.period_to) / 60.0
  end
end
