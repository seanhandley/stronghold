module OpenstackPathHelper
  def openstack_path
    case Rails.env
      when 'production'
        'https://compute.datacentred.io'
      else
        'http://devstack.datacentred.io'
      end
  end
end