class AddLocaleToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :locale, :string, null: false, default: 'en'
  end
end
