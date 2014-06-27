class AddOrganizationToSignups < ActiveRecord::Migration
  def change
    add_column :signups, :organization_id, :integer, null: true
  end
end
