module Billing
  class Instance < ActiveRecord::Base
    self.table_name = "billing_instances"

    validates :instance_id, uniqueness: true

    has_many :instance_states
    belongs_to :instance_image, :class_name => "Billing::Image",
               :primary_key => 'image_id', :foreign_key => 'image_id'
    belongs_to :tenant

    scope :active, -> { all.includes(:instance_states).select(&:active?) }

    def active?
      return false if instance_states.collect{|i| i.state.downcase }.include?('deleted')
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
      rate = instance_flavor.rates.where(arch: arch).first.rate rescue nil
      return rate if rate
      instance_flavor.rates.where(arch: 'x86_64').first.rate rescue nil
    end

    def instance_flavor
      flavor = instance_states.order('recorded_at').last.try(:instance_flavor)
      flavor || Billing::InstanceFlavor.find_by_flavor_id(flavor_id)
    end

    def fetch_states(from, to)
      states = instance_states.where(:recorded_at => from..to).order('recorded_at')
      if states.any?
        # Sometimes states arrive out of order and the final state by timestamp
        # isn't actually the final state. This can make instances appear to be
        # active, even after they're deleted.
        if states.collect(&:state).include?('deleted')
          found_deleted = false
          return states.take_while do |state| 
            begin
              !found_deleted
            ensure
              found_deleted = true if state.state == 'deleted'
            end
          end
        end
      end
      states
    end

    def resized?
      instance_states.map(&:flavor_id).uniq.count > 1
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