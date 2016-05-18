class IndexStatesRecordedAt < ActiveRecord::Migration
  def change
    add_index :billing_instance_states, :recorded_at
    add_index :billing_volume_states, :recorded_at
    add_index :billing_image_states, :recorded_at
    add_index :billing_ip_quotas, :recorded_at
    add_index :billing_ips, :recorded_at
    add_index :billing_storage_objects, :recorded_at
  end
end
