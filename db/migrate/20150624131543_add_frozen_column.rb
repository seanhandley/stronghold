class AddFrozenColumn < ActiveRecord::Migration
  def change
    add_column :organizations, :in_review, :boolean, null: false, default: false
  end
end
