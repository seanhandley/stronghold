class OrganizationGraphDecorator < ApplicationDecorator

  def to_json
    graph_data.to_json
  end

  def graph_data
    {
      "overall": {
        "capacity": {
          "used_percent": QuotaUsage.total_used_as_percent
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

  def quota_set_value(category, quota)
    model.projects.map{|p| p.quota_set[category][quota].to_i}.sum
  end

  def max_instances
    quota_set_value('compute', 'instances')
  end

  def max_vcpus
    quota_set_value('compute', 'cores')
  end

  def max_memory
    quota_set_value('compute', 'ram')
  end

  def max_volumes
    quota_set_value('volume', 'volumes')
  end

  def max_storage
    quota_set_value('volume', 'gigabytes')
  end

  def max_floatingip
    quota_set_value('network', 'floatingip')
  end

  def max_lbpools
    quota_set_value('network', 'pool')
  end


  def live_lb_pools
    return [] unless Rails.env.production? # Because LB support isn't on DevStack yet...
    LiveCloudResources.lb_pools.select{|s| model.projects.map(&:uuid).include?(s['tenant_id'])}
  end

  def live_floating_ips
    LiveCloudResources.floating_ips.select{|s| model.projects.map(&:uuid).include?(s['tenant_id'])}
  end

  def live_servers
    LiveCloudResources.servers.select{|s| model.projects.map(&:uuid).include?(s['tenant_id'])}
  end

  def live_volumes
    LiveCloudResources.volumes.select{|s| model.projects.map(&:uuid).include?(s["os-vol-tenant-attr:tenant_id"])}
  end
end
