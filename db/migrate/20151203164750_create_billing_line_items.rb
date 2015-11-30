class CreateBillingLineItems < ActiveRecord::Migration
  def change
    create_table :billing_line_items do |t|
      t.string :product_id
      t.integer :invoice_id
      t.integer :quantity
      t.timestamps
    end
  end
end
