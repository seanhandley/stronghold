module Billing
  class VolumeState < ActiveRecord::Base
    self.table_name = "billing_volume_states"

    validates :message_id, uniqueness: true

    belongs_to :billing_volume, :class_name => "Billing::Volume", :foreign_key => 'volume_id'
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'
    
  end
end