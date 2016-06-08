class StartedAt < ActiveRecord::Migration
  def change
    add_column :billing_instances, :started_at, :datetime
  end
end
