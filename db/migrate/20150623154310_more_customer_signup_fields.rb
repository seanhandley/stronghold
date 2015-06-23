class MoreCustomerSignupFields < ActiveRecord::Migration
  def change
    add_column :customer_signups, :user_agent, :string
    add_column :customer_signups, :accept_language, :string
  end
end
