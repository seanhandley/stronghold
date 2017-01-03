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

  def resource(name, state)
    case name
    when 'VCPUs'
      model.projects.map{|p| p.send "#{state}_vcpus".to_sym }.sum
    when 'Memory'
      model.projects.map{|p| p.send "#{state}_ram".to_sym }.sum
    when 'Storage'
      model.projects.map{|p| p.send "#{state}_storage".to_sym }.sum
    end
  end

  def resources_alert(name)
    used_percent = resource(name, 'available') > 0 ? resource(name, 'used') / resource(name, 'available').to_f : 0
    used_percent *= 100.0
    if used_percent.round > RESOURCE_THRESHOLD_PERCENTAGE
      name
    end
  end
end
