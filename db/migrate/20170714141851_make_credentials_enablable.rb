class MakeCredentialsEnablable < ActiveRecord::Migration[5.0]
  def change
    add_column :api_credentials, :enabled, :boolean, null: false, default: true
    add_index  :api_credentials, :enabled, name: "index_api_credentials_on_enabled", where: "(enabled IS FALSE)"
  end
end
