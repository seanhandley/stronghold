class AddSlowColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :slow_jobs, :boolean, default: false, null: false
  end
end
