module Billing
  class Instance < ActiveRecord::Base
    self.table_name = "billing_instances"

    has_many :instance_states
  end
end