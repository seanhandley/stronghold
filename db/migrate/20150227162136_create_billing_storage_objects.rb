class CreateBillingStorageObjects < ActiveRecord::Migration
  def change
    create_table :billing_storage_objects do |t|
      t.string :tenant_id
      t.float  :size
      t.datetime :recorded_at, limit: 3
      t.integer :sync_id
    end
  end
end
