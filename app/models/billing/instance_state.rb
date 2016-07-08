module Billing
  class InstanceState < ActiveRecord::Base
    self.table_name = "billing_instance_states"
   
    after_save  :link_previous, on: :create
    after_save  :link_next, on: :create
    after_save  :touch_instance, on: :create

    belongs_to :billing_instance, :class_name => "Billing::Instance", :foreign_key => 'instance_id'
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'

    belongs_to :instance_flavor, :class_name => "Billing::InstanceFlavor",
           :primary_key => 'flavor_id', :foreign_key => 'flavor_id'

    def first_state?
      previous_state.nil?
    end

    def last_state?
      next_state.nil?
    end

    def next_state
      InstanceState.find(next_state_id) if next_state_id
    end

    def previous_state
      InstanceState.find(previous_state_id) if previous_state_id
    end

    def rate(arch)
      arch = "x86_64" if arch == "None"
      flavor = instance_flavor ? instance_flavor : Billing::InstanceFlavor.find_by_flavor_id(billing_instance.flavor_id)
      flavor.rates.where(arch: arch).first.rate.to_f rescue nil
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

    def link_previous
      prev = (billing_instance.instance_states.where('recorded_at <= ?', recorded_at).order(:recorded_at).to_a - [self]).last
      update_column(:previous_state_id, prev.id) if prev
    end

    def link_next
      previous_state.update_column(:next_state_id, id) if previous_state
    end

  end
end