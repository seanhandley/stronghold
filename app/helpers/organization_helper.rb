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
    organizations = current_user.organizations.map{|org| [org.name, org.id]}
    options_for_select(organizations, current_organization.id)
  end
end
