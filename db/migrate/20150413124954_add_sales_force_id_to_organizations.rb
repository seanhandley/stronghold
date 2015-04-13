class AddSalesForceIdToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :salesforce_id, :string
  end
end
