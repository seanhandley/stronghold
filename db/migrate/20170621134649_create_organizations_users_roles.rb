class CreateOrganizationsUsersRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :organizations_users_roles do |t|
      t.integer :role_id
      t.integer :organization_user_id
      t.timestamps
    end
  end
end
