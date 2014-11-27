module Billing
  class Ip < ActiveRecord::Base
    self.table_name = "billing_ips"

    has_many :ip_states
  end
end