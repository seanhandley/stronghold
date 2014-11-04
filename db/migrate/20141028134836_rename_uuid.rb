class RenameUuid < ActiveRecord::Migration
  def change
    rename_column :tenants, :tenant_uuid,  :uuid
    rename_column :users,   :openstack_id, :uuid
  end
end
