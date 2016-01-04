module Billing
  class Ip < ApplicationRecord
    self.table_name = "billing_ips"

    validates :address, :project_id, :ip_type, :ip_id, presence: true

    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'
  end
end