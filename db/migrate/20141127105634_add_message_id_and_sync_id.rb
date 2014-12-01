class AddMessageIdAndSyncId < ActiveRecord::Migration
  def change
    add_column :billing_volume_states, :message_id, :string
    add_column :billing_ip_states,     :message_id, :string

    add_column :billing_instance_states, :sync_id, :integer
    add_column :billing_volume_states,   :sync_id, :integer
    add_column :billing_ip_states,       :sync_id, :integer
  end
end
