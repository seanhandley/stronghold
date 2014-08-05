class MakeActivityKeyString < ActiveRecord::Migration
  def change
    change_column :activities, :trackable_id, :string
  end
end
