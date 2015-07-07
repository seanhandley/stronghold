class AddRestrictedQuotaFieldToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :restricted, :boolean, default: false, null: false
  end
end
