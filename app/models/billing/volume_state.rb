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

    private

    def touch_volume
      billing_volume.update_attributes(deleted_at: recorded_at) if event_name == 'volume.delete.end'
    end
    
  end
end