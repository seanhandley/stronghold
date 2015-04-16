class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.string :name
      t.string :description
      t.string :code
      t.integer :duration # number of months
      t.integer :value
      t.datetime :expires_at
      t.timestamps
    end

    create_table :organization_vouchers do |t|
      t.integer :organization_id
      t.integer :voucher_id
      t.timestamps
    end
  end
end
