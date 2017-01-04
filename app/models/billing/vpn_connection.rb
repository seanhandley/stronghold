module Billing
  class VpnConnection < ApplicationRecord
    self.table_name = "billing_vpn_connections"

    validates :vpn_connection_id, uniqueness: true
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'
  end
end
