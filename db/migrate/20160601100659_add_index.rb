class AddIndex < ActiveRecord::Migration
  def change
    add_index :billing_volumes, :deleted_at
  end
end
