class AddProjectsLimitToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :projects_limit, :integer, null: false, default: 1
  end
end
