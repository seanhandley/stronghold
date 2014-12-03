class FloatingIpActive < ActiveRecord::Migration
  def change
    add_column :billing_ips, :active, :boolean, default: true, null: false
  end
end
