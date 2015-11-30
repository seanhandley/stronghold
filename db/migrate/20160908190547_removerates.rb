class Removerates < ActiveRecord::Migration
  def change
    drop_table :billing_rates
  end
end
