class CreateBillingInstances < ActiveRecord::Migration
  def change
    create_table :billing_instances do |t|
      t.string :instance_id
      t.string :name
      t.string :flavor_id
      t.string :image_id
      t.string :tenant_id
    end
  end
end
