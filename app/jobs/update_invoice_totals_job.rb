class UpdateInvoiceTotalsJob < ActiveJob::Base
  queue_as :default

  def perform(organization, year, month)
    organization.invoices.where(year: year, month: month).each(&:refresh_grand_total)
  end
end
