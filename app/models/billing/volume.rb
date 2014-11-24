module Billing
  class Volume < ActiveRecord::Base
    self.table_name = "billing_volumes"

    has_many :volume_states
  end
end