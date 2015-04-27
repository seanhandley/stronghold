class AddStateToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :state, :string, default: 'active', null: false
  end
end
