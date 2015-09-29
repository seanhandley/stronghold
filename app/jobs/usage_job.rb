class UsageJob < ActiveJob::Base
  queue_as :default

  def perform
    Billing.sync! unless already_running?
  end

  private

  def already_running?
    usage_job_count = Sidekiq::Workers.new.select do |process_id, thread_id, work|
      work['payload']['wrapped'] == 'UsageJob'
    end.count
    usage_job_count > 1
  end
end