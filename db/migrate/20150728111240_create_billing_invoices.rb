class CreateBillingInvoices < ActiveRecord::Migration
  def change
    create_table :billing_invoices do |t|
      t.integer :organization_id, null: false
      t.integer :year, null: false
      t.integer :month, null: false
      t.integer :sub_total, default: 0, null: false
      t.integer :grand_total, default: 0, null: false
      t.integer :discount_percent, default: 0, null: false
      t.integer :tax_percent, default: 20, null: false
      t.string  :stripe_invoice_id
      t.string  :salesforce_invoice_id
    end
  end
end
