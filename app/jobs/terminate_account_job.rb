class TerminateAccountJob < ActiveJob::Base
  include OffboardingHelper
  queue_as :default

  def perform(tenants)
    tenants.each {|tenant| offboard(tenant_uuid) }
  end
end