module Billing
  class InstanceState < ActiveRecord::Base
    self.table_name = "billing_instance_states"

    belongs_to :billing_instance, :class_name => "Billing::Instance", :foreign_key => 'instance_id'

  end
end