class AddRouterNameToGateways < ActiveRecord::Migration
  def change
    add_column :billing_external_gateways, :name, :string
    add_column :billing_external_gateway_states, :address, :string
  end
end
