class SalesforceSyncAllJob < ApplicationJob
  queue_as :default

  def perform
    # Warm up the cache before the threads have at it
    OpenStackConnection.usage((Time.now - 1.week).beginning_of_week, (Time.now - 1.week).end_of_week)
    OpenStackConnection.usage((Time.now - 1.month).beginning_of_month, (Time.now - 1.month).end_of_month)
    Organization.active.each do |organization|
      organization.update_salesforce_object
    end
  end
end