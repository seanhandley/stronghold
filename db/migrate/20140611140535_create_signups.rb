class CreateSignups < ActiveRecord::Migration
  def change
    create_table :signups do |t|
      t.string :email
      t.timestamps
      t.datetime :completed_at
      t.string :token
    end
  end
end
