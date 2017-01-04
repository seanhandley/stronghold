module Billing
  class LoadBalancer < ApplicationRecord
    self.table_name = "billing_load_balancers"

    validates :lb_id, uniqueness: true
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'
  end
end
