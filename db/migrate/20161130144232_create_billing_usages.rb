class CreateBillingUsages < ActiveRecord::Migration
  def change
    create_table :billing_usages do |t|
      t.integer :year
      t.integer :month
      t.integer :organization_id
      t.string  :object_uuid
      t.timestamps
    end
  end
end
