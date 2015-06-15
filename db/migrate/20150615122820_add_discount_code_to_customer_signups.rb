class AddDiscountCodeToCustomerSignups < ActiveRecord::Migration
  def change
    add_column :customer_signups, :discount_code, :string
  end
end
