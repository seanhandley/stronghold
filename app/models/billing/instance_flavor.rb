module Billing
  class InstanceFlavor < ApplicationRecord
    self.table_name = "billing_instance_flavors"

    has_many :billing_instances

  end
end