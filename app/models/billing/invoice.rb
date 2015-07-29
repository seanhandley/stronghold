module Billing
  class Invoice < ActiveRecord::Base

    self.table_name = "billing_invoices"

    belongs_to :organization

    validates :organization, :year, :month, presence: true

    scope :unfinalized, -> { all.where(stripe_invoice_id: nil) }

    def finalize!
      return false if stripe_invoice_id
      invoice_item = Stripe::InvoiceItem.create(customer: organization.stripe_customer_id,
                                                amount: to_pence(grand_total),
                                                currency: currency,
                                                description: invoice_description)

      invoice = Stripe::Invoice.create(customer: organization.stripe_customer_id,
                                       tax_percent: tax_percent)
      update_attributes(stripe_invoice_id: invoice.id)
    end

    def period_start
      Time.parse("#{year}-#{month}-1").beginning_of_month
    end

    def period_end
      period_start.end_of_month
    end

    def grand_total_plus_tax
      grand_total + (grand_total * (tax_percent.to_f / 100.0))
    end

    private

    def invoice_description
      discount_message = (discount_percent > 0) ? " (includes discount of #{discount_percent}%)" : ''
      "Cloud Usage #{Date::MONTHNAMES[month]} #{year}#{discount_message}. Invoice: #{salesforce_invoice_id})"
    end

    def currency
      'gbp'
    end

    def to_pence(amount_in_pounds)
      (amount_in_pounds * 100.0).ceil
    end

  end
end