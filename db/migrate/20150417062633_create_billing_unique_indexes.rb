class CreateBillingUniqueIndexes < ActiveRecord::Migration
  def change
    add_index :billing_instances, :instance_id, unique: true
    add_index :billing_volumes, :volume_id, unique: true
    add_index :billing_images, :image_id, unique: true
  end
end
