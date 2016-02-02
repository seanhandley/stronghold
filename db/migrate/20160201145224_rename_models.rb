class RenameModels < ActiveRecord::Migration
  def change
    rename_table :tenants, :projects
    rename_column :user_tenant_roles, :tenant_id, :project_id
    rename_table :user_tenant_roles, :user_project_roles
    rename_column :organizations, :primary_tenant_id, :primary_project_id
    rename_table :invites_tenants, :invites_projects
    rename_column :invites_projects, :tenant_id, :project_id
    rename_column :billing_external_gateways, :tenant_id, :project_id
    rename_column :billing_images, :tenant_id, :project_id
    rename_column :billing_instances, :tenant_id, :project_id
    rename_column :billing_ip_quotas, :tenant_id, :project_id
    rename_column :billing_ips, :tenant_id, :project_id
    rename_column :billing_storage_objects, :tenant_id, :project_id
    rename_column :billing_volumes, :tenant_id, :project_id
  end
end
