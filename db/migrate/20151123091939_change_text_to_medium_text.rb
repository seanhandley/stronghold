class ChangeTextToMediumText < ActiveRecord::Migration
  def change
    change_column :billing_usages, :usage_data, :text, limit: 64.megabytes - 1
  end
end
