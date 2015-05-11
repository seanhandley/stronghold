class TerminateAccountJob < ActiveJob::Base
  include OffboardingHelper
  queue_as :default

  def perform(tenant, creds)
    
  end
end