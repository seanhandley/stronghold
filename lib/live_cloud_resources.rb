module LiveCloudResources
  DEFAULT_CACHE_LIFETIME = 5.minutes

  def self.refresh_caches
    servers(refresh_cache: true);
    volumes(refresh_cache: true);
    floating_ips(refresh_cache: true);
    lb_pools(refresh_cache: true)
  end

  def self.servers(refresh_cache: false)
    Rails.cache.fetch("live_servers_dashboard", expires_in: DEFAULT_CACHE_LIFETIME, force: refresh_cache) do
      OpenStackConnection.compute.servers.all(all_tenants: true)
    end
  end

  def self.volumes(refresh_cache: false)
    Rails.cache.fetch("live_volumes_dashboard", expires_in: DEFAULT_CACHE_LIFETIME, force: refresh_cache) do
      OpenStackConnection.volume.volumes.all(all_tenants: true)
    end
  end

  def self.floating_ips(refresh_cache: false)
    Rails.cache.fetch("live_floating_ips_dashboard", expires_in: DEFAULT_CACHE_LIFETIME, force: refresh_cache) do
      OpenStackConnection.network.floating_ips.all
    end
  end

  def self.lb_pools(refresh_cache: false)
    Rails.cache.fetch("live_lb_poools_dashboard", expires_in: DEFAULT_CACHE_LIFETIME, force: refresh_cache) do
      OpenStackConnection.network.lb_pools.all
    end
  end
end
