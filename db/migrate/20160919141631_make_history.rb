class MakeHistory < ActiveRecord::Migration
  def change
    add_column :billing_instances, :cached_history, :text
  end
end
