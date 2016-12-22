class RaiseFinalInvoiceJob < ActiveJob::Base
  queue_as :default

  def perform(organization)
    killed_at = organization.transitions.where(to_state: 'closed').first
    ud = UsageDecorator.new(organization, killed_at.year, killed_at.month)
    ud.usage_data(force: true)
    BillingRunOrgJob.perform_later(organization, killed_at.year, killed_at.month)
  end
end