class AddIndexOrganizationState < ActiveRecord::Migration
  def change
    add_index :organizations, :state
  end
end
