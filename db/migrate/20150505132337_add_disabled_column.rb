class AddDisabledColumn < ActiveRecord::Migration
  def change
    add_column :organizations, :disabled, :boolean, default: false, null: false
  end
end
