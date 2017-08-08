class AddOrganizationUserIdToUserProjectRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :user_project_roles, :organization_user_id, :integer
  end
end
