module Billing
  class Volume < ApplicationRecord
    self.table_name = "billing_volumes"

    validates :volume_id, uniqueness: true

    has_many :volume_states

    scope :active, -> { where(deleted_at: nil) }

    def active?
      latest_state = volume_states.order('recorded_at').last
      latest_state ? Billing::Volumes.billable?(latest_state.event_name) : true
    end

    def reindex_states
      volume_states.each_cons(2) do |first, second|
        first.update_column(:next_state_id, second.id)
        second.update_column(:previous_state_id, first.id)
      end
      volume_states&.first&.update_column(:previous_state_id, nil)
      volume_states&.last&.update_column(:next_state_id, nil)
    end

    def created_at
      volume_states.where(event_name: 'volume.create.end').order('recorded_at').first.try(:recorded_at) { nil }
    end

    def deleted_at
      deleted_at = read_attribute(:deleted_at)
      return deleted_at if deleted_at
      deleted_at = volume_states.where(event_name: 'volume.delete.end').order('recorded_at').first.try(:recorded_at) { nil }
      update_attributes deleted_at: deleted_at
      deleted_at
    end

    def fetch_states(from, to)
      states = volume_states.where(:recorded_at => from..to)
      if states.any?
        # Sometimes states arrive out of order and the final state by timestamp
        # isn't actually the final state. This can make volumes appear to be
        # active, even after they're deleted.
        if states.collect(&:event_name).include?('volume.delete.end')
          found_deleted = false
          return states.take_while do |state| 
            begin
              !found_deleted
            ensure
              found_deleted = true if state.event_name == 'volume.delete.end'
            end
          end
        end
      end
      states
    end

    def history(from, to)
      history = fetch_states(from, to).to_a
      history.unshift(history.first.previous_state) if history&.first&.previous_state
      history = history.map do |state|
        state.to_hash(from, to)
      end
      return history if history.count > 0
      latest_state = volume_states.where("recorded_at < ?", from).last

      if latest_state && from >= latest_state.recorded_at
        return [latest_state.to_hash(from, to)] if latest_state&.billable?
      end
      []
    end

    def billable_history(from, to)
      history(from, to).select{|i| i[:billable]}
    end

    def terabyte_hours(from, to)
      Hash[billable_history(from, to).group_by{|i| i[:volume_type]}.map {|volume_type, volume_states|
        tbh = volume_states.sum{|i| (i[:seconds] / Billing::SECONDS_TO_HOURS) * (i[:size] / 1024.0)}
        [volume_type, tbh]
      }]
    end

    def cost_by_volume_type(from, to)
      Hash[
        terabyte_hours(from, to).map do |volume_type, hours|
          price = rate_for_volume_type(volume_type)
          [volume_type, price * hours]
        end
      ]
    end

    def rate_for_volume_type(volume_type)
      if Billing::Volumes.volume_name[volume_type].downcase.include?('ssd')
        RateCard.ssd_storage
      else
        RateCard.block_storage
      end
    end

    def cost(from, to)
      cost_by_volume_type(from, to).sum {|_,c| c}
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
      latest_state&.ssd?
    end
  end
end
