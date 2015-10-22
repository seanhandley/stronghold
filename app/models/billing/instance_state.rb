module Billing
  class InstanceState < ActiveRecord::Base
    self.table_name = "billing_instance_states"

    belongs_to :billing_instance, :class_name => "Billing::Instance", :foreign_key => 'instance_id'
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'

    belongs_to :instance_flavor, :class_name => "Billing::InstanceFlavor",
           :primary_key => 'flavor_id', :foreign_key => 'flavor_id'

    has_one :previous_state, class_name: "Billing::InstanceState", primary_key: 'previous_state_id', foreign_key: 'id'
    has_one :next_state, class_name: "Billing::InstanceState", primary_key: 'next_state_id', foreign_key: 'id'

    def hours_in_state
      hours = read_attribute(:hours_in_state)
      return hours if hours

      if next_state
        hours = ((next_state.recorded_at - recorded_at) / 3600.0).ceil
        write_attribute(:hours_in_state, hours)
        save!
        hours
      else
        ((Time.now - recorded_at) / 3600.0).ceil
      end
    end

    def billable_hours
      billable? ? hours_in_state : 0
    end

    def cost
      billable_hours * rate
    end

    def current_state?
      !!next_state
    end

    def rate
      arch = "x86_64" if arch == "None"
      flavor = instance_flavor ? instance_flavor : Billing::InstanceFlavor.find_by_flavor_id(billing_instance.flavor_id)
      flavor.rates.where(arch: arch).first.rate.to_f rescue nil
    end

    def billable?
      !["error", "building", "stopped", "suspended", "shutoff", "deleted"].include?(state.downcase)
    end

  end
end