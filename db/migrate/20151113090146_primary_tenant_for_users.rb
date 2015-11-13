class PrimaryTenantForUsers < ActiveRecord::Migration
  def change
    create_table :invites_tenants do |t|
      t.integer :invite_id
      t.integer :tenant_id
      t.timestamps
    end
  end
end
