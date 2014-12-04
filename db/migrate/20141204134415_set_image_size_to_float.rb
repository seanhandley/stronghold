class SetImageSizeToFloat < ActiveRecord::Migration
  def change
    change_column :billing_image_states, :size, :float
  end
end
