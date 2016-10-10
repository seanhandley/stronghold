class DontBill < ActiveRecord::Migration
  def change
    add_column :organizations, :bill_automatically, :boolean, default: true, null: false
  end
end
