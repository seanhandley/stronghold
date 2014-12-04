class CreateBillingImageStates < ActiveRecord::Migration
  def change
    create_table :billing_image_states do |t|
      t.datetime :recorded_at, limit: 3
      t.string   :event_name
      t.integer  :size
      t.integer  :image_id
      t.integer  :sync_id
      t.string   :message_id
    end
  end
end
