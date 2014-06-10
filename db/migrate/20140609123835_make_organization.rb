class MakeOrganization < ActiveRecord::Migration
  def change
    create_table :organizations do |t|
      t.string :reference
      t.string :name
      t.timestamps
    end
  end
end
