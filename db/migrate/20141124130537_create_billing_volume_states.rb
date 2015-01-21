class CreateBillingVolumeStates < ActiveRecord::Migration
  def change
    create_table :billing_volume_states do |t|
      t.datetime :recorded_at, limit: 3
      t.string   :event_name
      t.integer  :size
      t.integer  :volume_id
    end
  end
end
