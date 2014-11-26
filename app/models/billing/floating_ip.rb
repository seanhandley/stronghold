module Billing
  class FloatingIp < ActiveRecord::Base
    self.table_name = "billing_floating_ips"

    has_many :floating_ip_states
  end
end