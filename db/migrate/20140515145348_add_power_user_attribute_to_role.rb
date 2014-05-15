class AddPowerUserAttributeToRole < ActiveRecord::Migration
  def change
    add_column :roles, :power_user, :boolean, :default => false
  end
end
