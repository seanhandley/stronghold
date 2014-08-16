class AddSecretColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :api_key, :binary
    add_column :users, :api_key_key, :binary
    add_column :users, :api_key_iv, :binary
  end
end
