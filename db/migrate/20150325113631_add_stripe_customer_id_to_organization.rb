class AddStripeCustomerIdToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :stripe_customer_id, :string
  end
end
