class AddTestingFlagToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :test_account, :boolean, null: false, default: false
  end
end
