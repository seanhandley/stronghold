class DontUseFloats < ActiveRecord::Migration
  def change
    change_column :billing_storage_objects, :size,  :bigint
  end
end
