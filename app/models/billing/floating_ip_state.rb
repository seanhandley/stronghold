module Billing
  class FloatingIpState < ActiveRecord::Base
    self.table_name = "billing_floating_ip_states"

    belongs_to :billing_floating_ip, :class_name => "Billing::FloatingIp", :foreign_key => 'floating_ip_id'

  end
end