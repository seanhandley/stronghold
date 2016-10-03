class BillingRunOrgJob < ActiveJob::Base
  queue_as :default

  def perform(organization, year, month)
    # Skip if there's already an invoice for this year/month/org
    return if Billing::Invoice.where(organization: organization, year: year, month: month).any?

    invoice = Billing::Invoice.new(organization: organization, year: year, month: month)
    ud = UsageDecorator.new(organization)
    usage_data = ud.usage_data(from_date: invoice.period_start, to_date: invoice.period_end)
    if ud.sub_total > 0
      invoice.save!
      invoice.build_line_items(usage_data)
      invoice.update_attributes(discount_percent:  ud.discount_percent, tax_percent: ud.tax_percent)
    end
  end
end