class AddLimitedStorageFlag < ActiveRecord::Migration
  def change
    add_column :organizations, :limited_storage, :boolean, default: false, null: false
  end
end
