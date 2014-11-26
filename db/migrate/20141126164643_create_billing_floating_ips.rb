class CreateBillingFloatingIps < ActiveRecord::Migration
  def change
    create_table :billing_floating_ips do |t|
      t.string :floating_ip_id
      t.string :tenant_id
    end
  end
end
