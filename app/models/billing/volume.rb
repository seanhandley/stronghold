module Billing
  class Volume < ActiveRecord::Base
    self.table_name = "billing_volumes"

    validates :volume_id, uniqueness: true

    has_many :volume_states

    scope :active, -> { all.select(&:active?) }

    def active?
      latest_state = volume_states.order('recorded_at').last
      latest_state ? Billing::Volumes.billable?(latest_state.event) : true
    end
  end
end