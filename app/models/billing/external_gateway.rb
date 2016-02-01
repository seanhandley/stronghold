module Billing
  class ExternalGateway < ActiveRecord::Base
    self.table_name = "billing_external_gateways"

    validates :router_id, :project_id, presence: true

    has_many :external_gateway_states

    scope :active, -> { all.includes(:external_gateway_states).select(&:active?) }

    def active?
      latest_state = external_gateway_states.order('recorded_at').last
      latest_state ? Billing::ExternalGateways.billable?(latest_state) : true
    end
  end
end