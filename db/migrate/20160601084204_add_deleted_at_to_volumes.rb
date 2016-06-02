class AddDeletedAtToVolumes < ActiveRecord::Migration
  def change
    add_column :billing_volumes, :deleted_at, :datetime
  end
end
