class AddSignupColumn < ActiveRecord::Migration
  def change
    add_column :organizations, :customer_signup_id, :integer
  end
end
