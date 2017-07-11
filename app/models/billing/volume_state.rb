module Billing
  class VolumeState < ApplicationRecord
    self.table_name = "billing_volume_states"

    after_save :touch_volume, on: :create

    belongs_to :billing_volume, :class_name => "Billing::Volume", :foreign_key => 'volume_id'
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'

    def ssd?
      return false unless volume_type && Volumes.volume_name[volume_type]
      Volumes.volume_name[volume_type].upcase.include?('SSD')
    end

    def rate
      ssd? ? RateCard.ssd_storage : RateCard.block_storage
    end

    def first_state?
      previous_state.nil?
    end

    def last_state?
      next_state.nil?
    end

    def next_state
      VolumeState.find_by_id(next_state_id) if next_state_id
    end

    def previous_state
      VolumeState.find_by_id(previous_state_id) if previous_state_id
    end

    def billable?
      event_name != 'volume.delete.end'
    end

    def seconds(from, to)
      to = [to, next_state&.recorded_at].compact.min
      from = [from, recorded_at].compact.max
      to - from
    end

    def to_hash(from=nil, to=nil)
      {
        billable:    billable?,
        volume_type: volume_type,
        size:        size,
        seconds:     seconds(from, to),
        event_name:  event_name,
        user_id:     user_id,
        recorded_at: recorded_at
      }
    end

    private

    def touch_volume
      billing_volume.update_attributes(deleted_at: recorded_at) if event_name == 'volume.delete.end'
    end
    
  end
end