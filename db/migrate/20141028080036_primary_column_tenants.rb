class PrimaryColumnTenants < ActiveRecord::Migration
  def change
    add_column :organizations, :primary_tenant_id, :integer
  end
end
