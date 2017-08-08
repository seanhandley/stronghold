class AddOrganizationUserIdToApiCredentials < ActiveRecord::Migration[5.0]
  def change
    add_column :api_credentials, :organization_user_id, :integer
  end
end
