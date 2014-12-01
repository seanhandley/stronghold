class CreateExternalGatewayStates < ActiveRecord::Migration
  def change
    create_table :billing_external_gateway_states do |t|
      t.integer  :external_gateway_id
      t.string   :event_name
      t.string   :external_network_id
      t.datetime :recorded_at, limit: 3
      t.integer  :sync_id
      t.string   :message_id
    end
  end
end
