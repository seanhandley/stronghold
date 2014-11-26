class CreateBillingFloatingIpStates < ActiveRecord::Migration
  def change
    create_table :billing_floating_ip_states do |t|
      t.integer  :floating_ip_id
      t.string   :event_name
      t.datetime :recorded_at, limit: 3
    end
  end
end
