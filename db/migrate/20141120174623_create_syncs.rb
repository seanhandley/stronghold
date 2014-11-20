class CreateSyncs < ActiveRecord::Migration
  def change
    create_table :billing_syncs do |t|
      t.datetime :completed_at
    end
  end
end
