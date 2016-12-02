class UsersContacts < ActiveRecord::Migration
  def change
    create_table :users_contacts do |t|
      t.integer :user_id
      t.integer :contact_id
    end
  end
end
