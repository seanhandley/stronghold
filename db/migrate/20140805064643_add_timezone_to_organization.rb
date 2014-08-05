class AddTimezoneToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :time_zone, :string, default: 'London', null: false
  end
end
