module Billing
  class IpState < ActiveRecord::Base
    self.table_name = "billing_ip_states"
    
    validates :message_id, uniqueness: true

    belongs_to :billing_ip, :class_name => "Billing::Ip", :foreign_key => 'ip_id'
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'
    
  end
end