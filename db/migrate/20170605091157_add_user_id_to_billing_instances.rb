class AddUserIdToBillingInstances < ActiveRecord::Migration[5.0]
  def change
    add_column :billing_instance_states, :user_id, :string
    add_column :billing_volume_states, :user_id, :string
    add_column :billing_image_states, :user_id, :string
    add_column :billing_ips, :user_id, :string
    add_column :billing_load_balancers, :user_id, :string
    add_column :billing_vpn_connections, :user_id, :string
  end
end
