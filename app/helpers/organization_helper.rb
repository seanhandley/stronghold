module OrganizationHelper
  def cloud_resources_summary
    ogd = OrganizationGraphDecorator.new(current_organization)
    gd  = ogd.graph_data
    instances = gd[:compute][:instances][:used]
    volumes   = gd[:volume][:volumes][:used]
    "#{pluralize instances, 'instances'} and #{pluralize volumes, 'volumes'}"
  end

  def options_for_organization_contacts(selected=nil)
    options_for_select(current_organization.users.map(&:email), selected)
  end

  def organizations_for_select
    organizations = current_user.organizations.map{|org| [truncate(org.name, length: 18, separator: ' ', omission: '…'), org.id]}
    organizations.unshift(["Accounts:", ""])
    options_for_select(organizations, selected: current_organization.id, disabled: "")
  end
end
