class AddOrganizationId < ActiveRecord::Migration
  def change
    add_column :tenants, :organization_id, :integer
  end
end
