class ActivateCloudResourcesJob < ActiveJob::Base
  queue_as :default

  def perform(organization)
    organization.send :enable!
    organization.send :create_default_network!
    organization.send :set_quotas!
  end
end