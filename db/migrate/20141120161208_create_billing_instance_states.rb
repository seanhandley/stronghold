class CreateBillingInstanceStates < ActiveRecord::Migration
  def change
    create_table :billing_instance_states do |t|
      t.integer  :instance_id
      t.datetime :recorded_at
      t.string   :state
      t.string   :message_id
    end
  end
end
