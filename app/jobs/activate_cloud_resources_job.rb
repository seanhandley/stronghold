class ActivateCloudResourcesJob < ActiveJob::Base
  queue_as :default

  def perform(organization)
    organization.create_default_network!
    organization.set_quotas!
  end
end