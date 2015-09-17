class MakeUtRsUnique < ActiveRecord::Migration
  def change
    add_index :user_tenant_roles, ["user_id", "tenant_id", "role_uuid"], :unique => true
  end
end
