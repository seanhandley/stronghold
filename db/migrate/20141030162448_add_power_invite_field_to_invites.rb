class AddPowerInviteFieldToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :power_invite, :boolean, :default => false, :null => false
  end
end
