class AddCompletedAtToResets < ActiveRecord::Migration
  def change
    add_column :resets, :completed_at, :datetime
  end
end
