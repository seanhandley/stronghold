$usage_job_mutex = Mutex.new

class UsageJob < ActiveJob::Base
  queue_as :default

  def perform
    return if $usage_job_mutex.locked?
    $usage_job_mutex.synchronize do
      while(mins_since_sync > Billing::SYNC_INTERVAL_MINUTES) do
        Billing.sync!(Billing::SYNC_INTERVAL_MINUTES)
      end
    end
  end

  private

  def mins_since_sync
    last_sync = Billing::Sync.completed.last
    (Time.now - last_sync.period_to) / 60.0
  end
end
