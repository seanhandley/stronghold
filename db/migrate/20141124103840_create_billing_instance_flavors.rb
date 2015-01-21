class CreateBillingInstanceFlavors < ActiveRecord::Migration
  def change
    create_table :billing_instance_flavors do |t|
      t.string  :flavor_id
      t.string  :name
      t.integer :ram
      t.integer :disk
      t.integer :vcpus
    end
  end
end