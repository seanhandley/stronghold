class AddIndex < ActiveRecord::Migration
  def change
    add_index :billing_usages, :organization_id
  end
end
