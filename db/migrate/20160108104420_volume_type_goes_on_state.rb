class VolumeTypeGoesOnState < ActiveRecord::Migration
  def change
    remove_column :billing_volumes, :volume_type
    add_column :billing_volume_states, :volume_type, :string
  end
end
