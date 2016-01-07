module Billing
  class Volume < ActiveRecord::Base
    self.table_name = "billing_volumes"

    validates :volume_id, uniqueness: true

    has_many :volume_states

    scope :active, -> { all.includes(:volume_states).select(&:active?) }

    def active?
      latest_state = volume_states.order('recorded_at').last
      latest_state ? Billing::Volumes.billable?(latest_state.event_name) : true
    end

    def created_at
      volume_states.where(event_name: 'volume.create.end').order('recorded_at').first.try(:recorded_at) { nil }
    end

    def deleted_at
      volume_states.where(event_name: 'volume.delete.end').order('recorded_at').first.try(:recorded_at) { nil }
    end

    def latest_state
      @latest_state ||= volume_states.order('recorded_at').last
    end

    def latest_size
      latest_state.try(:size) { nil }
    end

    def volume_type
      latest_state.try(:volume_type) { nil }
    end

    def ssd?
      latest_state.ssd?
    end
  end
end
