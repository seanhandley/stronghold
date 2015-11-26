class TextLimits < ActiveRecord::Migration
  def change
    change_column :organizations, :quota_limit, :text, limit: 64.kilobytes - 1, default: nil, null: true
    change_column :tenants, :quota_set, :text, limit: 64.kilobytes - 1, default: nil, null: true
  end
end
