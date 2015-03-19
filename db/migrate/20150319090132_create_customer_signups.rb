class CreateCustomerSignups < ActiveRecord::Migration
  def change
    create_table :customer_signups do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :company_name
      t.timestamps
    end
  end
end
