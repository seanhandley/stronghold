class CustomerEnableAccountJob < ActiveJob::Base
  queue_as :default

  def perform(organization_id, stripe_customer_id)
    organization = Organization.find(organization_id)
    organization.enable!(stripe_customer_id)
  end
end