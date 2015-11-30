class Invoices < ActiveRecord::Migration
  def change
    change_column :billing_invoices, :grand_total, :integer, null: true
    add_column    :billing_invoices, :finalized, :boolean, null: false, default: false
  end
end
