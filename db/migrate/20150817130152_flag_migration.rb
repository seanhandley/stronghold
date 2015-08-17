class FlagMigration < ActiveRecord::Migration
  def change
    add_column :customer_signups, :retro_migrated, :boolean
  end
end
