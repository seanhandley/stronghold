class OrgLimits < ActiveRecord::Migration
  def change
    default = <<TEXT
---
compute:
  instances: 10
  cores: 10
  ram: 20480
volume:
  volumes: 4
  snapshots: 4
  gigabytes: 40
network:
  floatingip: 1
  router: 1

TEXT
    add_column :organizations, :quota_limit, :string, default: default
    add_column :tenants, :quota_set, :string, default: default
  end
end
