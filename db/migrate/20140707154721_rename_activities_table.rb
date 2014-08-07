class RenameActivitiesTable < ActiveRecord::Migration
  def change
    rename_table :activities, :audits
  end
end
