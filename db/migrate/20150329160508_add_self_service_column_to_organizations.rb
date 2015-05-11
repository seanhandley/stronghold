class AddSelfServiceColumnToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :self_service, :boolean, null: false, default: true
  end
end
