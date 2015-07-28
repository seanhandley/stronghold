class Floats < ActiveRecord::Migration
  def change
    change_column :billing_invoices, :sub_total, :float
    change_column :billing_invoices, :grand_total, :float
  end
end
