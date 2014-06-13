class RenameSignups < ActiveRecord::Migration
  def change
    rename_table :signups, :invites
    rename_table :roles_signups, :invites_roles
    rename_column :invites_roles, :signup_id, :invite_id
  end
end
