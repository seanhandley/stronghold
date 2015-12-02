class AddSalesForceIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :salesforce_id, :string
  end
end
