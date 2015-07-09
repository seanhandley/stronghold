class AddArchToBillingInstance < ActiveRecord::Migration
  def change
    add_column :billing_instances, :arch, :string
  end
end
