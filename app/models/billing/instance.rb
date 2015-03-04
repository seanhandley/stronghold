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
  end
end