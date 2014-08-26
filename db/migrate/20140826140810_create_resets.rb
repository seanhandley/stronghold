class CreateResets < ActiveRecord::Migration
  def change
    create_table :resets do |t|
      t.string :email
      t.string :token
      t.timestamps
    end
  end
end
