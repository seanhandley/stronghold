class RenameTenantId < ActiveRecord::Migration
  def change
    rename_column :tenants, :tenant_id, :tenant_uuid
  end
end
