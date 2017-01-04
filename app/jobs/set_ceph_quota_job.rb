class SetCephQuotaJob < ApplicationJob
  queue_as :default

  def perform(organization)
    organization.projects.collect(&:uuid).each do |project_id|
      if organization.limited_storage?
        Ceph::UserQuota.set_limited(project_id)
      else
        Ceph::UserQuota.set_unlimited(project_id)
      end
    end
  end
end