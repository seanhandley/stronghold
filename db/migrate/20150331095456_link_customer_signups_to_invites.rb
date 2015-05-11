class LinkCustomerSignupsToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :customer_signup_id, :integer
  end
end
