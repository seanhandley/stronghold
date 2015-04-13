class SalesforceSyncJob < ActiveJob::Base
  queue_as :default

  def perform(lambda)
    lambda.call
  end
end