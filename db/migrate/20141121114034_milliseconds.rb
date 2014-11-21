class Milliseconds < ActiveRecord::Migration
  def change
    change_column :billing_instance_states, :recorded_at, :datetime, limit: 3
    change_column :billing_syncs, :completed_at, :datetime, limit: 3
  end
end
