class AddUuidToRoles < ActiveRecord::Migration[5.0]
  def change
    add_column :roles, :uuid, :string
  end
end
