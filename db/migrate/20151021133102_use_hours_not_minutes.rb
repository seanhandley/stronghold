class UseHoursNotMinutes < ActiveRecord::Migration
  def change
    [
      :billing_instance_states,
      :billing_volume_states,
      :billing_image_states,
      :billing_external_gateway_states,
      :billing_ip_states
    ].each do |table|
      rename_column table, :minutes_in_state, :hours_in_state
    end

  end
end
