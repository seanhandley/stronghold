module Billing
  class Instance < ActiveRecord::Base
    self.table_name = "billing_instances"

    validates :instance_id, uniqueness: true

    has_many :instance_states
    belongs_to :instance_flavor, :class_name => "Billing::InstanceFlavor",
               :primary_key => 'flavor_id', :foreign_key => 'flavor_id'

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

    def current_state
      return 'terminated' if terminated_at
      Instances.billable?(instance_states.order('recorded_at').last.try(:state)) ? 'active' : 'stopped'
    end

    def latest_state(from, to)
      return 'terminated' if terminated_at && terminated_at <= to # and terminated between from, to
      Instances.billable?(instance_states.where(:recorded_at => from..to).order('recorded_at').last.try(:state)) ? 'active' : 'stopped'
    end
  end
end