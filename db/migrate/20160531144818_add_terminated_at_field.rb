class AddTerminatedAtField < ActiveRecord::Migration
  def change
    add_column :billing_instances, :terminated_at, :datetime
  end
end
