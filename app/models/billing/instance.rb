module Billing
  class Instance < ActiveRecord::Base
    self.table_name = "billing_instances"

    validates :instance_id, uniqueness: true

    has_many :instance_states
    belongs_to :instance_image, :class_name => "Billing::Image",
               :primary_key => 'image_id', :foreign_key => 'image_id'
    belongs_to :project

    serialize :cached_history

    scope :active, -> { where(terminated_at: nil) }

    def metadata
      images = Rails.cache.fetch("billing_images", expires_in: 1.hour) do
        OpenStackConnection.compute.list_images_detail.body['images']
      end

      images = images.select{|image| image['id'] == image_id}

      if images.any?
        images[0]['metadata']
      else
        {}
      end
    end

    def reindex_states
      instance_states.each_cons(2) do |first, second|
        first.update_column(:next_state_id, second.id)
        second.update_column(:previous_state_id, first.id)
      end
      instance_states&.first&.update_column(:previous_state_id, nil)
      instance_states&.last&.update_column(:next_state_id, nil)
    end

    def terminated_at
      terminated_at = read_attribute(:terminated_at)
      return terminated_at if terminated_at
      terminated_at = instance_states.where(state: 'deleted').first.try(:recorded_at) { nil }
      update_attributes terminated_at: terminated_at
      terminated_at
    end
    
    def first_booted_at
      instance_states.where(state: 'active').first.try(:recorded_at) { nil }
    end

    def instance_flavor
      flavor = instance_states.last.try(:instance_flavor)
      flavor || Billing::InstanceFlavor.find_by_flavor_id(flavor_id)
    end

    def fetch_states(from, to)
      states = instance_states.where(:recorded_at => from..to)
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

    def cached_history
      read_attribute(:cached_history) || {}
    end

    def history(from, to, flush=false)
      update_column(:cached_history, {}) if flush
      key = history_key(from, to)
      ch = cached_history.dup
      unless ch[key]
        ch[key] = fetch_history(from, to)
        update_column(:cached_history, ch)
      end
      ch[key]
    end

    def history_key(from, to)
      "#{from.to_s}_#{to.to_s}"
    end

    def fetch_history(from, to)
      history = fetch_states(from, to).to_a
      history.unshift(history.first.previous_state) if history&.first&.previous_state
      history = history.map do |state|
        state.to_hash(from, to)
      end
      return history if history.count > 0
      latest_state = instance_states.where("recorded_at < ?", from).last

      if latest_state && from >= latest_state.recorded_at
        return [latest_state.to_hash(from, to)] if latest_state&.billable?
      end
      []
    end

    def billable_history(from, to)
      history(from, to).select{|i| i[:billable]}
    end

    def billable_seconds(from, to)
      Hash[billable_history(from, to).group_by{|i| i[:flavor]}.map {|flavor, instances|
        [flavor, instances.sum{|i| i[:seconds]}]
      }]
    end

    def billable_hours(from, to)
      Hash[billable_seconds(from, to).map {|flavor, seconds|
        [flavor, (seconds / Billing::SECONDS_TO_HOURS).ceil]
      }]
    end

    def cost(from, to)
      cost_by_flavor(from, to).sum {|_,c| c}
    end

    def cost_by_flavor(from, to)
      Hash[billable_hours(from, to).map {|flavor, hours|
        begin
          product_id = Salesforce.find_instance_product(flavor)['salesforce_id']
          price = Salesforce::Product.all[product_id][:price]
          [flavor, price * hours]
        rescue StandardError => e
          Honeybadger.notify(StandardError.new("No flavor: #{flavor}"))
          nil
        end
      }.compact]
    end

    def latest_state(from, to)
      return 'terminated' if terminated_at && terminated_at <= to # and terminated between from, to
      state = instance_states.where('recorded_at <= ?', to).last
      if state
        state.billable? ? 'active' : 'stopped'
      else
        'unknown'
      end
    end
  end
end