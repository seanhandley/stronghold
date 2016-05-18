class AddIndexBillingInstances < ActiveRecord::Migration
  def change
    add_index :billing_instances, :terminated_at
  end
end
