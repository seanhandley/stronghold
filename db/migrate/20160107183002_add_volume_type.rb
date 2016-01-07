class AddVolumeType < ActiveRecord::Migration
  def change
    add_column :billing_volumes, :volume_type, :string
  end
end
