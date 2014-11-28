class CreateExternalGateways < ActiveRecord::Migration
  def change
    create_table :billing_external_gateways do |t|
      t.string :router_id
      t.string :address
      t.string :tenant_id
    end
  end
end
