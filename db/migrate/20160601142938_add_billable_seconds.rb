class AddBillableSeconds < ActiveRecord::Migration
  def change
    add_column :billing_instances, :billable_seconds, :integer
    add_column :billing_instances, :cost, :float
  end
end
