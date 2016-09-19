class SalesforceId < ActiveRecord::Migration
  def change
    rename_column :billing_invoices, :salesforce_invoice_id, :salesforce_id
  end
end
