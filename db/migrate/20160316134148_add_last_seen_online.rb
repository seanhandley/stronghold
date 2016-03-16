class AddLastSeenOnline < ActiveRecord::Migration
  def change
    add_column :users, :last_seen_online, :datetime
  end
end
