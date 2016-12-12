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
    (object_percent("memory") + object_percent("vcpu") + object_percent("storage")).to_f / 3.0
  end

  def object_percent(object)
    a = projects_limits
    b = total_usage
    arr2 = b.map{|x| x[object].to_f}
    arr1 = a.map{|y| y[object].to_f}
    percent_per_project = [arr1, arr2].transpose.map {|x| x.inject { |lim, usg| lim == 0 ? lim : usg * 100 / lim }}
    percent_per_project.reduce(:+).to_f / 3.0
  end
end
