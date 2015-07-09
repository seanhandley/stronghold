module Billing
  class Rate < ActiveRecord::Base
    self.table_name = "billing_rates"

    belongs_to :instance_flavor, :class_name => "Billing::InstanceFlavor",
               :primary_key => 'flavor_id', :foreign_key => 'flavor_id'
  end
end