class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.timestamps
    end

    create_table :organizations_products do |t|
      t.integer :organization_id
      t.integer :product_id
      t.timestamps
    end
  end
end
