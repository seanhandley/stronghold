class AddStorageObjectsIndex < ActiveRecord::Migration
  def change
    add_index :billing_storage_objects, :project_id
  end
end
