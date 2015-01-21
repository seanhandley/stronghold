class RecordEventName < ActiveRecord::Migration
  def change
    add_column :billing_instance_states, :event_name, :string
  end
end
