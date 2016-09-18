module OrganizationHelper
  def cloud_resources_summary
    ogd = OrganizationGraphDecorator.new(current_organization)
    gd  = ogd.graph_data
    instances = gd[:compute][:instances][:used]
    volumes   = gd[:volume][:volumes][:used]
    "#{pluralize instances, 'instances'} and #{pluralize volumes, 'volumes'}"
  end
end