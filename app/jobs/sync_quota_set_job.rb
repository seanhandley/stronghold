class SyncQuotaSetJob < ActiveJob::Base
  queue_as :default

  def perform(tenant)
    quota = StartingQuota['standard'].deep_merge(tenant.quota_set)

    OpenStackConnection.compute.update_quota tenant.uuid, Hash[quota['compute'].map{|k,v| [k, v.to_i]}]
    OpenStackConnection.volume.update_quota  tenant.uuid, Hash[quota['volume'].map{|k,v| [k, v.to_i]}]
    OpenStackConnection.network.update_quota tenant.uuid, Hash[quota['network'].map{|k,v| [k, v.to_i]}]
  end
end
