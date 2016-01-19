module Billing
  class VolumeState < ActiveRecord::Base
    self.table_name = "billing_volume_states"

    belongs_to :billing_volume, :class_name => "Billing::Volume", :foreign_key => 'volume_id'
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'

    def ssd?
      return false unless volume_type && Volumes.volume_name[volume_type]
      Volumes.volume_name[volume_type].upcase.include?('SSD')
    end

    def rate
      ssd? ? RateCard.ssd_storage : RateCard.block_storage
    end
    
  end
end