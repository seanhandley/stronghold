class CreateBillingImages < ActiveRecord::Migration
  def change
    create_table :billing_images do |t|
      t.string :image_id
      t.string :name
      t.string :tenant_id
    end
  end
end
