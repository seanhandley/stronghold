class AddNavigableInstanceEventColumns < ActiveRecord::Migration
  def change
    add_column :billing_instance_states, :previous_state_id, :integer
    add_column :billing_instance_states, :next_state_id,     :integer

    add_index :billing_instance_states, :previous_state_id
    add_index :billing_instance_states, :next_state_id
  end
end
