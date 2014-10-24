class RemoveUnusedUserFields < ActiveRecord::Migration
  def change
    remove_column :users, :password_digest
    remove_column :users, :api_key
    remove_column :users, :api_key_key
    remove_column :users, :api_key_iv
  end
end
