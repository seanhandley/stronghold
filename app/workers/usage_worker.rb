class UsageWorker
  include Sidekiq::Worker

  def perform
    Billing::Instances.sync!
  end
end