class CreateUsagesTable < ActiveRecord::Migration
  def change
    create_table :billing_usages do |t|
      t.integer :year, null: false
      t.integer :month, null: false
      t.integer :organization_id, null: false
      t.text :usage_data, null: false
    end
  end
end
