class InvoiceTimestamps < ActiveRecord::Migration
  def change
    add_timestamps(:billing_invoices)
  end
end
