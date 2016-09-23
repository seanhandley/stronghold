class LongText < ActiveRecord::Migration
  def change
    change_column :billing_instances, :cached_history, :text, :limit => 4294967295
  end
end
