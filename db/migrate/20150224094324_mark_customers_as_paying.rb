class MarkCustomersAsPaying < ActiveRecord::Migration
  def change
    add_column :organizations, :paying, :boolean, default: false, null: false
  end
end
