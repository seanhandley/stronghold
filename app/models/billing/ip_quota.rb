module Billing
  class IpQuota < ApplicationRecord
    self.table_name = "billing_ip_quotas"
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'

    def as_json(params)
      {
        current_quota: quota,
        recorded_at: recorded_at,
        previous_quota: previous
      }
    end
  end
end