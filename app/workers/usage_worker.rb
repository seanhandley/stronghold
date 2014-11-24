class UsageWorker
  include Sidekiq::Worker

  def perform
    Billing.sync!
  end
end