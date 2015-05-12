class CreateWaitListEntriesTable < ActiveRecord::Migration
  def change
    create_table :wait_list_entries do |t|
      t.string :email
      t.datetime :emailed_at
      t.timestamps
    end
  end
end
