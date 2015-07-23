module Billing
  class Instance < ActiveRecord::Base
    self.table_name = "billing_instances"

    validates :instance_id, uniqueness: true

    has_many :instance_states
    belongs_to :instance_image, :class_name => "Billing::Image",
               :primary_key => 'image_id', :foreign_key => 'image_id'

    scope :active, -> { all.select(&:active?) }

    def active?
      latest_state = instance_states.order('recorded_at').last
      latest_state ? Billing::Instances.billable?(latest_state.state) : true
    end

    def terminated_at
      instance_states.where(state: 'deleted').order('recorded_at').first.try(:recorded_at) { nil }
    end

    def first_booted_at
      instance_states.where(state: 'active').order('recorded_at').first.try(:recorded_at) { nil }
    end

    def rate
      instance_flavor.rates.where(arch: arch).first.rate rescue nil
    end

    def instance_flavor
      instance_states.order('recorded_at').last.try(:instance_flavor) { Billing::InstanceFlavor.find(flavor_id) }
    end

    def current_state
      return 'terminated' if terminated_at
      Instances.billable?(latest_state) ? 'active' : 'stopped'
    end

    def latest_state(from, to)
      return 'terminated' if terminated_at && terminated_at <= to # and terminated between from, to
      state = instance_states.where('recorded_at <= ?', to).order('recorded_at').last.try(:state)
      if state
        Instances.billable?(state) ? 'active' : 'stopped'
      else
        'unknown'
      end
    end
  end
end