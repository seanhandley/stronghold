class CreateProjectDefaultNetworkJob < ActiveJob::Base
  queue_as :default

  def perform(project_uuid)
    return if Rails.env.acceptance?
    ProjectResources.new(project_uuid).create_default_network unless ['test','development'].include?(Rails.env)
  end
end