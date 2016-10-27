class OrganizationUsageDecorator < ApplicationDecorator
  RESOURCE_THRESHOLD_PERCENTAGE = 90

  def threshold_message
    "You are reaching your #{active_organization_resources.to_sentence} quota limit" if over_threshold?
  end

  def over_threshold?
    active_organization_resources.any?
  end

  private

  def active_organization_resources
    [
      resources_alert('VCPUs'),
      resources_alert('Memory'),
      resources_alert('Storage')
    ].compact
  end

  def used_resource(resource)
    case resource
    when 'VCPUs'
      model.projects.map{|p| p.used_vcpus}.sum
    when 'Memory'
      model.projects.map{|p| p.used_ram}.sum
    when 'Storage'
      model.projects.map{|p| p.used_storage}.sum
    end
  end

  def resource_limit(resource)
    case resource
    when 'VCPUs'
      model.projects.map{|p| p.available_vcpus}.sum
    when 'Memory'
      model.projects.map{|p| p.available_ram}.sum
    when 'Storage'
      model.projects.map{|p| p.available_storage}.sum
    end
  end

  def resources_alert(resource)
    used_percent = resource_limit(resource) > 0 ? used_resource(resource) / resource_limit(resource) : 0
    if used_percent > RESOURCE_THRESHOLD_PERCENTAGE
      resource
    end
  end
end
