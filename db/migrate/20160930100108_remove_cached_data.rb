class RemoveCachedData < ActiveRecord::Migration
  def change
    remove_column :billing_instances, :cached_history
  end
end
