module Billing
  class InstanceState < ApplicationRecord
    self.table_name = "billing_instance_states"
   
    after_save :touch_instance, on: :create

    belongs_to :billing_instance, :class_name => "Billing::Instance", :foreign_key => 'instance_id'
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'

    belongs_to :instance_flavor, :class_name => "Billing::InstanceFlavor",
           :primary_key => 'flavor_id', :foreign_key => 'flavor_id'

    default_scope { order(:recorded_at, :id) }

    def first_state?
      previous_state.nil?
    end

    def last_state?
      next_state.nil?
    end

    def next_state
      InstanceState.find_by_id(next_state_id) if next_state_id
    end

    def previous_state
      InstanceState.find_by_id(previous_state_id) if previous_state_id
    end

    def billable?
      delete_states = billing_instance.instance_states.where(state: 'deleted')
      return false if delete_states.any?{|s| s.recorded_at < recorded_at}
      !["error","building", "stopped", "suspended", "shutoff", "deleted", "resized"].include?(state.downcase)
    end

    def seconds(from, to)
      to = [to, next_state&.recorded_at].compact.min
      from = [from, recorded_at].compact.max
      to - from
    end

    def to_hash(from=nil, to=nil)
      {
        billable:    billable?,
        event_name:  event_name,
        flavor:      instance_flavor.flavor_id,
        seconds:     seconds(from, to).ceil,
        recorded_at: recorded_at,
        state:       state,
        user_id:     user_id
      }
    end

    private

    def touch_instance
      billing_instance.update_attributes(terminated_at: recorded_at) if state == 'deleted'
      if billing_instance.started_at.nil?
        billing_instance.update_attributes(started_at: recorded_at)
      elsif(recorded_at < billing_instance.started_at)
        billing_instance.update_attributes(started_at: recorded_at)
      end
    end

  end
end