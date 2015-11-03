class HideRates < ActiveRecord::Migration
  def change
    add_column :billing_rates, :show, :boolean, default: true, null: false
  end
end
