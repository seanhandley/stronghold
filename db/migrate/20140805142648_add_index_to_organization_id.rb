class AddIndexToOrganizationId < ActiveRecord::Migration
  def change
    add_index :audits, [:organization_id], name: "index_audits_on_organization_id", using: :btree
  end
end
