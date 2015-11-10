class WeeklySpend < ActiveRecord::Migration
  def change
    add_column :organizations, :weekly_spend, :float, null: false, default: 0
  end
end
