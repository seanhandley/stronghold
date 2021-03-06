module Billing
  class LineItem < ApplicationRecord

    self.table_name = "billing_line_items"

    syncs_with_salesforce as: 'c2g__codaInvoiceLineItem__c', actions: [:create]

    after_commit :refresh_invoice

    def salesforce_args
      {
        c2g__Invoice__c: invoice.salesforce_id,
        c2g__Product__c: product_id,
        c2g__Quantity__c: quantity.round(2),
        c2g__LineDescription__c: description
      }
    end

    belongs_to :invoice, :class_name => "Billing::Invoice",
       :foreign_key => 'invoice_id'

    private

    def refresh_invoice
      invoice.refresh_grand_total
    end
  end
end