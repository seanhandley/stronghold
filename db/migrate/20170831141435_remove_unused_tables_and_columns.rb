class RemoveUnusedTablesAndColumns < ActiveRecord::Migration[5.0]
  def change
    remove_column :api_credentials, :user_id
    remove_column :api_credentials, :organization_id
    remove_column :unread_tickets,  :user_id
    remove_column :users,           :organization_id

    drop_table :roles_users
  end
end
