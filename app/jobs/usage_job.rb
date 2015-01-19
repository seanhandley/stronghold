class UsageJob < ActiveJob::Base
  queue_as :default

  def perform
    Billing.sync!
  end
end