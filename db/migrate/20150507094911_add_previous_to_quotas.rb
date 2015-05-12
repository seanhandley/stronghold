class AddPreviousToQuotas < ActiveRecord::Migration
  def change
    add_column :billing_ip_quotas, :previous, :integer
  end
end
