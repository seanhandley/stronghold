class ChangeVoucherDurations < ActiveRecord::Migration[5.0]
  def change
    change_column_default :vouchers, :duration, 30
    Voucher.all.each do |v|
      v.update_attributes duration: (v.duration * 30)
    end
  end
end
