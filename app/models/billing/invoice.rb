module Billing
  class Invoice < ActiveRecord::Base

    self.table_name = "billing_invoices"

    belongs_to :organization

    validates :organization, :year, :month, presence: true

    scope :unfinalized, -> { all.where(stripe_invoice_id: nil) }
    scope :finalized, -> { all.where('stripe_invoice_id is not null') }

    def finalize!
      return false if stripe_invoice_id
      if salesforce_invoice_id.blank?
        errors.add(:salesforce_invoice_id, 'must not be blank')
        return false
      end

      begin
        invoice_item = Stripe::InvoiceItem.create(customer: organization.stripe_customer_id,
                                                amount: to_pence(grand_total),
                                                currency: currency,
                                                description: invoice_description)

        invoice = Stripe::Invoice.create(customer: organization.stripe_customer_id)
        update_attributes(stripe_invoice_id: invoice.id)
      rescue StandardError => e
        if invoice_item
          begin
            invoice_item.delete
          rescue StandardError => e
            notify_honeybadger(e)
          end
        end

        if invoice
          invoice.delete
        end
      end
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

    def salesforce_invoice_link
      salesforce_invoice_id.present? ? "https://eu2.salesforce.com/_ui/search/ui/UnifiedSearchResults?str=#{salesforce_invoice_id}" : ''
    end


    def stripe_invoice_link
      stripe_invoice_id.present? ? "https://dashboard.stripe.com/invoices/#{stripe_invoice_id}" : ''
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