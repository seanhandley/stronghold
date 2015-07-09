module Billing
  class InstanceFlavor < ActiveRecord::Base
    self.table_name = "billing_instance_flavors"

    has_many :billing_instances

    has_many :billing_rates
  end
end