class SyncStartedAt < ActiveRecord::Migration
  def change
    add_column :billing_syncs, :started_at, :datetime, limit: 3
  end
end
