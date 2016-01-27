class CreateRolesTenants < ActiveRecord::Migration
  def change
    create_table :roles_tenants do |t|
      t.integer :role_id
      t.integer :tenant_id
      t.timestamps
    end
  end
end
