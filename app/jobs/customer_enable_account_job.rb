class CustomerEnableAccountJob < ActiveJob::Base
  queue_as :default

  def perform(organization_id, stripe_customer_id)
    organization = Organization.find(organization_id)
    organization.update_attributes(stripe_customer_id: stripe_customer_id)
    organization.enable!
  end
end