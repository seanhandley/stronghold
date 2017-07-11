class AddNavigableVolumeEventColumns < ActiveRecord::Migration[5.0]
  def change
    add_column :billing_volume_states, :previous_state_id, :integer
    add_column :billing_volume_states, :next_state_id,     :integer

    add_index :billing_volume_states, :previous_state_id
    add_index :billing_volume_states, :next_state_id
  end
end
