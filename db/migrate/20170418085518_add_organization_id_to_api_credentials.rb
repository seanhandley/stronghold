class AddOrganizationIdToApiCredentials < ActiveRecord::Migration[5.0]
  def change
    add_column :api_credentials, :organization_id, :integer
  end
end
