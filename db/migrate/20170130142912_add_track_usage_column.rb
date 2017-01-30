class AddTrackUsageColumn < ActiveRecord::Migration[5.0]
  def change
    add_column :organizations, :track_usage, :boolean, null: false, default: true
    add_index  :organizations, :track_usage, where: "track_usage"
  end
end
