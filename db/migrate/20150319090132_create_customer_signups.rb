class CreateCustomerSignups < ActiveRecord::Migration
  def change
    create_table :customer_signups do |t|
      t.string :uuid
      t.string :email
      t.string :organization_name
      t.string :stripe_customer_id
      t.timestamps
    end
  end
end
