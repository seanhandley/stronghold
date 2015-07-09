class CreateBillingRates < ActiveRecord::Migration
  def change
    create_table :billing_rates do |t|
      t.integer :flavor_id
      t.string :arch
      t.float :rate
    end
  end
end
