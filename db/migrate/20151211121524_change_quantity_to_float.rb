class ChangeQuantityToFloat < ActiveRecord::Migration
  def change
    change_column :billing_line_items, :quantity, :float
  end
end
