class AddMoreFieldsToCustomerSignup < ActiveRecord::Migration
  def change
    add_column :customer_signups, :device_id, :string
    add_column :customer_signups, :activation_attempts, :integer, default: 0, null: false
  end
end
