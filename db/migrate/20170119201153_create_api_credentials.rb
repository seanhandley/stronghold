class CreateApiCredentials < ActiveRecord::Migration[5.0]
  def change
    create_table :api_credentials do |t|
      t.integer :user_id
      t.string  :access_key
      t.string  :password_digest
      t.timestamps
    end
  end
end
