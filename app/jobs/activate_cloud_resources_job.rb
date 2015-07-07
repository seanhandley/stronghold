class ActivateCloudResourcesJob < ActiveJob::Base
  queue_as :default

  def perform(organization, voucher=nil)
    organization.send :enable!
    organization.send :create_default_network!
    organization.send :set_quotas!, voucher
  end
end