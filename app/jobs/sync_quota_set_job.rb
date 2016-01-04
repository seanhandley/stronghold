class SyncQuotaSetJob < ApplicationJob
  queue_as :default

  def perform(project)
    return if Rails.env.acceptance?
    quota = StartingQuota['standard'].deep_merge(project.quota_set)

    OpenStackConnection.compute.update_quota project.uuid, Hash[quota['compute'].map{|k,v| [k, v.to_i]}]
    OpenStackConnection.volume.update_quota  project.uuid, Hash[quota['volume'].map{|k,v| [k, v.to_i]}]
    OpenStackConnection.network.update_quota project.uuid, Hash[quota['network'].map{|k,v| [k, v.to_i]}]
  end
end
