class CreateRolesUsers < ActiveRecord::Migration
  def change
    create_table :roles_users do |t|
      t.integer :role_id
      t.integer :user_id
      t.timestamps
    end
  end
end
