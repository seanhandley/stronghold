class IndexOrganizationProjects < ActiveRecord::Migration
  def change
    add_index :projects, :organization_id
  end
end
