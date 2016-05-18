class ChangeColumnName < ActiveRecord::Migration
  def change
    rename_column :organizations, :email, :billing_contact
  end
end
