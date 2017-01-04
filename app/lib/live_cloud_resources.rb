module LiveCloudResources
  DEFAULT_CACHE_LIFETIME = 10.minutes
  MAX_LIMIT = 1000 # This is set on the Nova/Cinder APIs

  def self.refresh_caches
    servers(refresh_cache: true);
    volumes(refresh_cache: true);
    floating_ips(refresh_cache: true);
    lb_pools(refresh_cache: true)
  end

  def self.servers(refresh_cache: false)
    Rails.cache.fetch("live_servers", expires_in: DEFAULT_CACHE_LIFETIME, force: refresh_cache) do
      all_pages(:compute, :list_servers_detail, 'servers', 1000, all_tenants: true)
    end
  end

  def self.volumes(refresh_cache: false)
    Rails.cache.fetch("live_volumes", expires_in: DEFAULT_CACHE_LIFETIME, force: refresh_cache) do
      all_pages(:volume, :list_volumes_detailed, 'volumes', 1000, all_tenants: true)
    end
  end

  def self.images(refresh_cache: false)
    Rails.cache.fetch("live_images", expires_in: DEFAULT_CACHE_LIFETIME, force: refresh_cache) do
      all_pages(:image, :list_images, 'images', 25)
    end
  end

  def self.floating_ips(refresh_cache: false)
    Rails.cache.fetch("live_floating_ips", expires_in: DEFAULT_CACHE_LIFETIME, force: refresh_cache) do
      OpenStackConnection.network.list_floating_ips.body['floatingips']
    end
  end

  def self.lb_pools(refresh_cache: false)
    Rails.cache.fetch("live_lb_poools", expires_in: DEFAULT_CACHE_LIFETIME, force: refresh_cache) do
      OpenStackConnection.network.list_lb_pools.body['pools']
    end
  end

  private

  def self.all_pages(collection, endpoint, key, max, params={})
    last_seen = nil
    results = []
    while true do
      params.merge!(last_seen ? {marker: last_seen} : {})
      batch  = OpenStackConnection.send(collection).send(endpoint, params).body[key]
      results << batch
      break if batch.count < max
      last_seen = batch.last['id']
    end
    results.flatten
  end
end
