module Billing
  class IpQuota < ActiveRecord::Base
    self.table_name = "billing_ip_quotas"
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'
  end
end