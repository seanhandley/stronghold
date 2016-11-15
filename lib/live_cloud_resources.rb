module LiveCloudResources
  def self.refresh_caches
    servers(true); volumes(true); floating_ips(true); lb_pools(true)
  end

  def self.servers(force=false)
    Rails.cache.fetch("live_servers_dashboard", expires_in: 5.minutes, force: force) do
      OpenStackConnection.compute.servers.all(all_tenants: true)
    end
  end

  def self.volumes(force=false)
    Rails.cache.fetch("live_volumes_dashboard", expires_in: 5.minutes, force: force) do
      OpenStackConnection.volume.volumes.all(all_tenants: true)
    end
  end

  def self.floating_ips(force=false)
    Rails.cache.fetch("live_floating_ips_dashboard", expires_in: 5.minutes, force: force) do
      OpenStackConnection.network.floating_ips.all
    end
  end

  def self.lb_pools(force=false)
    Rails.cache.fetch("live_lb_poools_dashboard", expires_in: 5.minutes, force: force) do
      OpenStackConnection.network.lb_pools.all
    end
  end
end
