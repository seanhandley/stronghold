class SoftDeleteTenants < ActiveRecord::Migration
  def change
    add_column :tenants, :deleted_at, :datetime
    add_index :tenants, :deleted_at
  end
end
