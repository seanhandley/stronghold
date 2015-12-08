class StoreFromToSyncs < ActiveRecord::Migration
  def change
    add_column :billing_syncs, :period_from, :datetime, precision: 3
    add_column :billing_syncs, :period_to,   :datetime, precision: 3
  end
end
