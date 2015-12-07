class UsageJob < ActiveJob::Base
  queue_as :default

  def perform(mins=0)
    to = Time.now + mins.minutes
    Billing.sync!(to) unless already_running?
  end

  private

  def already_running?
    usage_job_count = Sidekiq::Workers.new.select do |process_id, thread_id, work|
      work['payload']['wrapped'] == 'UsageJob'
    end.count
    usage_job_count > 1
  end
end