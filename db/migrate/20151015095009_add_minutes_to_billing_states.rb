class AddMinutesToBillingStates < ActiveRecord::Migration
  def change
    [
      :billing_instance_states,
      :billing_volume_states,
      :billing_image_states,
      :billing_external_gateway_states,
      :billing_ip_states
    ].each do |table|
      add_column table, :timestamp, :datetime
      add_column table, :minutes_in_state, :integer
      add_column table, :previous_state_id, :integer
      add_column table, :next_state_id, :integer
    end

  end
end
