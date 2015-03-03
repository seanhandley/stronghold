class StartedPayingAt < ActiveRecord::Migration
  def change
    remove_column :organizations, :paying
    add_column :organizations, :started_paying_at, :datetime
  end
end
