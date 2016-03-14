class CreateVpnConnections < ActiveRecord::Migration
  def change
    create_table :billing_vpn_connections do |t|
      t.string :vpn_connection_id
      t.string :name
      t.string :project_id
      t.datetime :started_at
      t.datetime :terminated_at
      t.integer :sync_id
      t.timestamps
    end
  end
end
