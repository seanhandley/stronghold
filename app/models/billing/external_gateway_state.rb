module Billing
  class ExternalGatewayState < ActiveRecord::Base
    self.table_name = "billing_external_gateway_states"

    belongs_to :billing_external_gateway, :class_name => "Billing::ExternalGateway"
    belongs_to :billing_sync, :class_name => "Billing::Sync", :foreign_key => 'sync_id'

  end
end