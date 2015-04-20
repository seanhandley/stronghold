class CreateVouchers < ActiveRecord::Migration
  def change
    create_table :vouchers do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :code, null: false
      t.integer :duration, limit: 1, default: 1, null: false
      t.decimal :discount_percent, precision: 3, default: 10, null: false
      t.datetime :expires_at
      t.timestamps
    end

    create_table :organization_vouchers do |t|
      t.integer :organization_id
      t.integer :voucher_id
      t.timestamps
    end

    add_index :organization_vouchers, [:organization_id, :voucher_id], unique: true
    add_index :vouchers, :code, unique: true
  end
end
