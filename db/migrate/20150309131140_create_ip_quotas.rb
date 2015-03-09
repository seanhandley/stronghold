class CreateIpQuotas < ActiveRecord::Migration
  def change
    create_table :billing_ip_quotas do |t|
      t.string :tenant_id
      t.integer  :quota
      t.datetime :recorded_at, limit: 3
      t.integer :sync_id
    end
  end
end
