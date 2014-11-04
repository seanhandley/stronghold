class CreateUserTenantRoles < ActiveRecord::Migration
  def change
    create_table :user_tenant_roles do |t|
      t.integer :user_id
      t.integer :tenant_id
      t.string  :role_uuid
    end
  end
end
