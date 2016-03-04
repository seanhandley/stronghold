class CreateBillingLoadBalancers < ActiveRecord::Migration
  def change
    create_table :billing_load_balancers do |t|
      t.string :lb_id
      t.string :name
      t.string :project_id
      t.datetime :started_at
      t.datetime :terminated_at
      t.integer :sync_id
      t.timestamps
    end
  end
end
