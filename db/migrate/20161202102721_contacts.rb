class Contacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :type
      t.integer :organization_id
      t.timestamps
    end
  end
end
