class AddTechnicalContactToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :technical_contact, :string
  end
end
