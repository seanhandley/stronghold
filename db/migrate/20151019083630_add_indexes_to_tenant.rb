class AddIndexesToTenant < ActiveRecord::Migration
  def change
    add_index(:billing_external_gateways, :tenant_id, name: 'tenant_external_gateways')
    add_index(:billing_images,            :tenant_id, name: 'tenant_images')
    add_index(:billing_instances,         :tenant_id, name: 'tenant_instances')
    add_index(:billing_ips,               :tenant_id, name: 'tenant_ips')
    add_index(:billing_volumes,           :tenant_id, name: 'tenant_volumes')
    add_index(:billing_storage_objects,   :tenant_id, name: 'tenant_storage_objects')
    add_index(:billing_ip_quotas,         :tenant_id, name: 'tenant_ip_quotas')
  end
end
