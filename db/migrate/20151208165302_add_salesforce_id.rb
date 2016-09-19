class AddSalesforceId < ActiveRecord::Migration
  def change
    add_column :billing_line_items, :salesforce_id, :string
  end
end
