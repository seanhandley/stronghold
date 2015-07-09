module Billing
  class InstanceFlavor < ActiveRecord::Base
    self.table_name = "billing_instance_flavors"

    has_many :billing_instances

    has_many :billing_rates, :class_name => "Billing::Rate",
               :primary_key => 'flavor_id', :foreign_key => 'flavor_id'
  end
end