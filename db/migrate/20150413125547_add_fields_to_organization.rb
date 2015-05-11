class AddFieldsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :billing_address1, :string
    add_column :organizations, :billing_address2, :string
    add_column :organizations, :billing_city, :string
    add_column :organizations, :billing_postcode, :string
    add_column :organizations, :billing_country, :string
    add_column :organizations, :phone, :string
  end
end
