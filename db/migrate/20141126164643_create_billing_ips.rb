class CreateBillingIps < ActiveRecord::Migration
  def change
    create_table :billing_ips do |t|
      t.string :ip_id
      t.string :address
      t.string :tenant_id
    end
  end
end
