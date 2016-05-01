class UsageJob < ActiveJob::Base
  queue_as :default

  def perform
    return if already_running?
    while(mins_since_sync > Billing::SYNC_INTERVAL_MINUTES) do
      Billing.sync!(Billing::SYNC_INTERVAL_MINUTES)
    end
    Billing.sync!
  end

  private

  def mins_since_sync
    last_sync = Billing::Sync.completed.last
    (Time.now - last_sync.period_to) * 60.0
  end

  def already_running?
    usage_job_count = Sidekiq::Workers.new.select do |process_id, thread_id, work|
      work['payload']['wrapped'] == 'UsageJob'
    end.count
    usage_job_count > 1
  end
end