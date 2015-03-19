class CreateCustomerSignups < ActiveRecord::Migration
  def change
    create_table :customer_signups do |t|
      t.string :uuid
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :organization_name
      t.boolean :payment_verified, default: false, null: false
      t.timestamps
    end
  end
end
