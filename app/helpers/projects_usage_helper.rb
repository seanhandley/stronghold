module ProjectsUsageHelper
  def get_projects
    ls = OrganizationGraphDecorator.new(current_organization)
    ls.projects
  end

  def projects_limits
    gp = get_projects
    limits = gp.map{|k|
      {
        'memory' => k.quota_set['compute']['ram'],
        'vcpu' => k.quota_set['compute']['cores'],
        'storage' => k.quota_set['volume']['gigabytes']
      }
    }
  end

  def project_used_resources(uuid)
    {
      'memory' => project_used_ram(uuid),
      'vcpu' => project_used_vcpus(uuid),
      'storage' => project_used_storage(uuid)
    }
  end

  def project_used_ram(uuid)
    OpenStackConnection.compute.get_quota(uuid).body['quota_set']['ram']
  end

  def project_used_vcpus(uuid)
    OpenStackConnection.compute.get_quota(uuid).body['quota_set']['cores']
  end

  def project_used_storage(uuid)
    OpenStackConnection.volume.get_quota(uuid).body['quota_set']['gigabytes']
  end

  def total_usage
    gp = get_projects
    usage = gp.map{|p|
      {
        'memory' => project_used_resources(p.uuid)['memory'],
        'vcpu' => project_used_resources(p.uuid)['vcpu'],
        'storage' => project_used_resources(p.uuid)['storage']
      }
    }
  end

  def percent_used
    (memory_percent + vcpu_percent + storage_percent)/3.0
  end

  def memory_percent
    a = projects_limits
    b = total_usage
    a.select{|x|  b.map{|p| x['memory'].to_f == 0 ? x['memory'].to_f : (p['memory'].to_f * 100)/ x['memory'].to_f}}.sum
  end

  def vcpu_percent
    a = projects_limits
    b = total_usage
    a.select{|x|  b.map{|p| x['vcpu'].to_f == 0 ? x['vcpu'].to_f : (p['vcpu'].to_f * 100)/ x['vcpu'].to_f}}.sum
  end

  def storage_percent
    a = projects_limits
    b = total_usage
    a.select{|x|  b.map{|p| x['storage'].to_f == 0 ? x['storage'].to_f : (p['storage'].to_f * 100)/ x['storage'].to_f}}.sum
  end
end
