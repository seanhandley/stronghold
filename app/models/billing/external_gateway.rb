module Billing
  class ExternalGateway < ActiveRecord::Base
    self.table_name = "billing_external_gateways"

    validates :router_id, :tenant_id, presence: true

    has_many :external_gateway_states
  end
end