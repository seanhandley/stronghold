class AddOrganizationIdToRole < ActiveRecord::Migration
  def change
    add_column :roles, :organization_id, :integer
  end
end
