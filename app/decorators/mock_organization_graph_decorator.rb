class MockOrganizationGraphDecorator < ApplicationDecorator

  def to_json
    graph_data.to_json
  end

  def graph_data
    {
      "overall": {
        "capacity": {
          "used_percent": 60
        }
      },
      "compute": {
        "instances": {
          "used": 25,
          "available": 50 - 25
        },
        "cores": {
          "used": 20,
          "available": 30 - 20
        },
        "memory": {
          "used": 10240,
          "available": 61440 - 10240
        },
        # "flavors": instance_flavors.map do |k,v|
        #   {
        #     "name": k,
        #     "count": v
        #   }
        # end
        "flavors": [
          {
            "name": "dc1.1x0",
            "count": 5
          },
          {
            "name": "dc1.1x1",
            "count": 5
          },
          {
            "name": "dc1.1x1.80",
            "count": 1
          },
          {
            "name": "dc1.1x1.20",
            "count": 5
          },
          {
            "name": "dc1.2x2.40",
            "count": 5
          },
          {
            "name": "dc1.1x2.20",
            "count": 5
          },
          {
            "name": "dc1.2x2",
            "count": 5
          },
          {
            "name": "dc1.1x2",
            "count": 5
          },
          {
            "name": "dc1.1x2.80",
            "count": 3
          },
          {
            "name": "dc1.2x4.40",
            "count": 5
          },
          {
            "name": "dc1.2x4",
            "count": 10
          },
          {
            "name": "dc1.4x8",
            "count": 5
          },
          {
            "name": "dc1.2x8.40",
            "count": 5
          },
          {
            "name": "dc1.2x8",
            "count": 10
          },
          {
            "name": "dc1.8x16",
            "count": 5
          },
          {
            "name": "dc1.4x16",
            "count": 5
          },
          {
            "name": "dc1.8x32",
            "count": 5
          },
          {
            "name": "dc1.16x32",
            "count": 2
          }
        ]
      },
      "volume": {
        "volumes": {
          "used": 6,
          "available": 12 - 6
        },
        "storage": {
          "used": 60,
          "available": 120 - 60
        }
      },
      "network": {
        "floatingip": {
          "used": 15,
          "available": 20 - 15
        },
        "lbpools": {
          "used": 12,
          "available": 20 - 12
        }
      }
    }
  end

  def self.refresh_caches
    live_servers(true); live_volumes(true); live_floating_ips(true); live_lb_pools(true)
  end

  private

  def used_percent
    ([
      [vcpus_count,    max_vcpus],
      [memory_count,   max_memory],
      [storage_gb,     max_storage]
    ].map do |e|
      ((e[0].to_f / e[1].to_f) * 100)
    end.sum / 3.0).round
  end

  def instance_count
    live_servers.count
  end

  def vcpus_count
    live_servers.map{|s| Billing::InstanceFlavor.find_by_flavor_id(s['flavor']['id']).vcpus}.sum
  end

  def memory_count
    live_servers.map{|s| Billing::InstanceFlavor.find_by_flavor_id(s['flavor']['id']).ram}.sum
  end

  def instance_flavors
    flavor_names  = live_servers.map{|s| Billing::InstanceFlavor.find_by_flavor_id(s['flavor']['id']).name}
    flavor_pairs  = flavor_names.group_by{|a| a}.map{|k,v| [k, v.count]}
    Hash[flavor_pairs]
  end

  def storage_gb
    live_volumes.map{|s| s["size"] }.sum
  end

  def storage_count
    live_volumes.count
  end

  def floating_ip_count
    live_floating_ips.count
  end

  def lb_pools_count
    live_lb_pools.count
  end

  def set_quota_value(category, quota)
    model.projects.map{|p| p.quota_set[category][quota].to_i}.sum
  end

  def max_instances
    set_quota_value('compute', 'instances')
  end

  def max_vcpus
    set_quota_value('compute', 'cores')
  end

  def max_memory
    set_quota_value('compute', 'ram')
  end

  def max_volumes
    set_quota_value('volume', 'volumes')
  end

  def max_storage
    set_quota_value('volume', 'gigabytes')
  end

  def max_floatingip
    set_quota_value('network', 'floatingip')
  end

  def max_lbpools
    set_quota_value('network', 'pool')
  end

  def self.live_lb_pools(force=false)
    Rails.cache.fetch("live_lb_poools_dashboard", expires_in: 5.minutes, force: force) do
      OpenStackConnection.network.list_lb_pools.body['pools']
    end
  end

  def live_lb_pools
    return [] unless Rails.env.production? # Because LB support isn't on DevStack yet...
    OrganizationGraphDecorator.live_lb_pools.select{|s| model.projects.map(&:uuid).include?(s['tenant_id'])}
  end

  def self.live_floating_ips(force=false)
    Rails.cache.fetch("live_floating_ips_dashboard", expires_in: 5.minutes, force: force) do
      OpenStackConnection.network.list_floating_ips.body['floatingips']
    end
  end

  def live_floating_ips
    OrganizationGraphDecorator.live_floating_ips.select{|s| model.projects.map(&:uuid).include?(s['tenant_id'])}
  end

  def self.live_servers(force=false)
    Rails.cache.fetch("live_servers_dashboard", expires_in: 5.minutes, force: force) do
      OpenStackConnection.compute.list_servers_detail(all_tenants: true).body['servers']
    end
  end

  def live_servers
    OrganizationGraphDecorator.live_servers.select{|s| model.projects.map(&:uuid).include?(s['tenant_id'])}
  end

  def self.live_volumes(force=false)
    Rails.cache.fetch("live_volumes_dashboard", expires_in: 5.minutes, force: force) do
      OpenStackConnection.volume.list_volumes_detailed(all_tenants: true).body['volumes']
    end
  end

  def live_volumes
    OrganizationGraphDecorator.live_volumes.select{|s| model.projects.map(&:uuid).include?(s["os-vol-tenant-attr:tenant_id"])}
  end
end
