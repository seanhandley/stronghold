module Billing
  class Volume < ActiveRecord::Base
    self.table_name = "billing_volumes"

    validates :volume_id, uniqueness: true

    has_many :volume_states
  end
end