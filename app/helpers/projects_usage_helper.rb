module ProjectsUsageHelper
  def get_projects
    ls = OrganizationGraphDecorator.new(current_organization)
    # ls.projects.collect(&:name).sort
    ls.projects
  end

  def projects_limits
    gp = get_projects
    limits = gp.map{|k| {'vcpu:' => k.quota_set['compute']['cores'], 'memory:' => k.quota_set['compute']['ram'], 'storage:' => k.quota_set['volume']['gigabytes']}}
    limits
  end

  def projects_usage
    gp = get_projects
  end
end
