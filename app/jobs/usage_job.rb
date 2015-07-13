class UsageJob < ActiveJob::Base
  queue_as :default

  # sidekiq_options unique: true

  def perform
    Billing.sync!
  end
end