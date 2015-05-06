class TerminateAccountJob < ActiveJob::Base
  include OffboardingHelper
  queue_as :default

  def perform(tenant)
    offboard(tenant)
  end
end