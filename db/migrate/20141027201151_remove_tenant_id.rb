class RemoveTenantId < ActiveRecord::Migration
  def change
    remove_column :organizations, :tenant_id
  end
end
