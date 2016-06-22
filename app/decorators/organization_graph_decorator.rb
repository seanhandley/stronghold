class OrganizationGraphDecorator < ApplicationDecorator

  def to_json
    graph_data.to_json
  end

  def graph_data
    {
      "overall": {
        "capacity": {
          "used_percent": used_percent
        }
      },
      "compute": {
        "instances": {
          "used": instance_count,
          "available": max_instances - instance_count
        },
        "cores": {
          "used": vcpus_count,
          "available": max_vcpus - vcpus_count
        },
        "memory": {
          "used": memory_count,
          "available": max_memory - memory_count
        },
        "flavors": instance_flavors.map do |k,v|
          {
            "name": k,
            "count": v
          }
        end
      },
      "volume": {
        "volumes": {
          "used": storage_count,
          "available": max_volumes - storage_count
        },
        "storage": {
          "used": storage_gb,
          "available": max_storage - storage_gb
        }
      },
      "network": {
        "floatingip": {
          "used": floating_ip_count,
          "available": max_floatingip - floating_ip_count
        },
        "lbpools": {
          "used": lb_pools_count,
          "available": max_lbpools - lb_pools_count
        }
      }
    }
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

  def live_lb_pools
    return [] unless Rails.env.production? # Because LB support isn't on DevStack yet...
    Rails.cache.fetch("live_lb_poools_dashboard", expires_in: 5.minutes) do
      OpenStackConnection.network.list_lb_pools.body['pools']
    end.select{|s| model.projects.map(&:uuid).include?(s['tenant_id'])}
  end

  def live_floating_ips
    Rails.cache.fetch("live_floating_ips_dashboard", expires_in: 5.minutes) do
      OpenStackConnection.network.list_floating_ips.body['floatingips']
    end.select{|s| model.projects.map(&:uuid).include?(s['tenant_id'])}
  end

  def live_servers
    Rails.cache.fetch("live_servers_dashboard", expires_in: 5.minutes) do
      OpenStackConnection.compute.list_servers_detail(all_tenants: true).body['servers']
    end.select{|s| model.projects.map(&:uuid).include?(s['tenant_id'])}
  end

  def live_volumes
    Rails.cache.fetch("live_volumes_dashboard", expires_in: 5.minutes) do
      OpenStackConnection.volume.list_volumes_detailed(all_tenants: true).body['volumes']
    end.select{|s| model.projects.map(&:uuid).include?(s["os-vol-tenant-attr:tenant_id"])}
  end

  def max_instances
    model.projects_limit * model.quota_limit['compute']['instances'].to_i
  end

  def max_vcpus
    model.projects_limit * model.quota_limit['compute']['cores'].to_i
  end

  def max_memory
    model.projects_limit * model.quota_limit['compute']['ram'].to_i
  end

  def max_volumes
    model.projects_limit * model.quota_limit['volume']['volumes'].to_i
  end

  def max_storage
    model.projects_limit * model.quota_limit['volume']['gigabytes'].to_i
  end

  def max_floatingip
    model.projects_limit * model.quota_limit['network']['floatingip'].to_i
  end

  def max_lbpools
    model.projects_limit * model.quota_limit['network']['network'].to_i
  end

end
