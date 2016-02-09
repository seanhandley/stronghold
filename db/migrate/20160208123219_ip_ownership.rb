class IpOwnership < ActiveRecord::Migration
  def change
    drop_table :billing_external_gateways
    drop_table :billing_external_gateway_states
    drop_table :billing_ip_states
    remove_column :billing_ips, :active
    add_column :billing_ips, :recorded_at, :datetime, :limit => 3
    add_column :billing_ips, :message_id, :string
    add_column :billing_ips, :ip_type, :string
    add_column :billing_ips, :sync_id, :integer
  end
end
