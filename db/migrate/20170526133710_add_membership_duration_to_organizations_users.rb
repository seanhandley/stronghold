class AddMembershipDurationToOrganizationsUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations_users, :duration, :integer
  end
end
