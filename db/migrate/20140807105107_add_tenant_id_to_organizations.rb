class AddTenantIdToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :tenant_id, :string
  end
end
