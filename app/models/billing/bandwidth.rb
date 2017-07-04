module Billing
  class Bandwidth < ActiveRecord::Base
    self.table_name = "billing_bandwidths"

    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'
    
  end
end