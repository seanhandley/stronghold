class AddPriceToInstanceFlavours < ActiveRecord::Migration
  def change
    add_column :billing_instance_flavors, :rate, :float
  end
end
