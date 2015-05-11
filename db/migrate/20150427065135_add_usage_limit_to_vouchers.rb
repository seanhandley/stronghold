class AddUsageLimitToVouchers < ActiveRecord::Migration
  def change
    add_column :vouchers, :usage_limit, :integer
  end
end
