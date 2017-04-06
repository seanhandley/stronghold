class AddPrimaryColumnToOrganizationsUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations_users, :primary, :boolean, default: false, null: false
  end
end
