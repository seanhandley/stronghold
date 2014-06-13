class CreateSignupRoles < ActiveRecord::Migration
  def change
    create_table :roles_signups do |t|
      t.integer :role_id
      t.integer :signup_id
      t.timestamps
    end
  end
end
