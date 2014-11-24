class CreateBillingVolumes < ActiveRecord::Migration
  def change
    create_table :billing_volumes do |t|
      t.string :volume_id
      t.string :name
      t.string :tenant_id
    end
  end
end
