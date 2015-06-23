class AddFieldsToCustomerSignup < ActiveRecord::Migration
  def change
    add_column :customer_signups, :real_ip, :string
    add_column :customer_signups, :forwarded_ip, :string
  end
end
