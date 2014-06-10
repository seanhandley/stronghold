class UsersOrganizationId < ActiveRecord::Migration
  def change
    add_column :users, :organization_id, :integer
  end
end
