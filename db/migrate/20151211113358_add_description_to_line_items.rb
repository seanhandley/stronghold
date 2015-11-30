class AddDescriptionToLineItems < ActiveRecord::Migration
  def change
    add_column :billing_line_items, :description, :string
  end
end
