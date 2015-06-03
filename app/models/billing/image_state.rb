module Billing
  class ImageState < ActiveRecord::Base
    self.table_name = "billing_image_states"

    belongs_to :billing_image, :class_name => "Billing::Image", :foreign_key => 'image_id'
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'
    
  end
end