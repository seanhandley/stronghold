class AddReportingCode < ActiveRecord::Migration
  def change
    add_column :organizations, :reporting_code, :string
    add_index :organizations, :reporting_code, unique: true
  end
end
