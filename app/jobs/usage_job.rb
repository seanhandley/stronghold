class UsageJob < ActiveJob::Base
  queue_as :default

  def perform
    Billing.sync! unless already_running?
  end

  private

  def already_running?
    Sidekiq::Workers.new.each do |process_id, thread_id, work|
      return true if work['payload']['wrapped'] == 'UsageJob'
    end
    false
  end
end