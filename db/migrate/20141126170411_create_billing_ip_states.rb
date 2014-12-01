class CreateBillingIpStates < ActiveRecord::Migration
  def change
    create_table :billing_ip_states do |t|
      t.integer  :ip_id
      t.string   :event_name
      t.string   :port
      t.datetime :recorded_at, limit: 3
    end
  end
end
