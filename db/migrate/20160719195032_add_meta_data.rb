class AddMetaData < ActiveRecord::Migration
  def change
    add_column :organizations, :metadata, :string
  end
end
