class CreateBillingBandwidths < ActiveRecord::Migration
  def change
    create_table :billing_bandwidths do |t|
      t.string :project_id
      t.float :gigabytes, limit: 8
      t.integer :sync_id
      t.datetime :from
      t.datetime :to
      t.timestamps
    end
  end
end
