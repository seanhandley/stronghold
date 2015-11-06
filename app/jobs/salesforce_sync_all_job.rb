class SalesforceSyncAllJob < ActiveJob::Base
  queue_as :default

  def perform
    Organization.active.each do |organization|
      organization.update_salesforce_object
    end
  end
end