class ActivateCloudResourcesJob < ApplicationJob
  queue_as :default

  def perform(organization, voucher=nil)
    organization.projects.each do |project|
      next if OpenStackConnection.network.list_routers(tenant_id: project.uuid).body['routers'].count > 0
      ProjectResources.new(project.uuid).create_default_network if Rails.env.production? && !organization.colo_only?
    end
    organization.set_quotas! voucher
  end
end
