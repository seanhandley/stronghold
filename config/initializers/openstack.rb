settings = YAML.load_file("#{Rails.root}/config/openstack.yml")[Rails.env]

OPENSTACK_ARGS = {
  :provider           => 'OpenStack',
  :openstack_auth_url => settings['auth_url'],
  :openstack_username => ENV["OPENSTACK_USERNAME"],
  :openstack_api_key  => ENV["OPENSTACK_PASSWORD"],
  :openstack_tenant   => ENV["OPENSTACK_TENANT"]
}

Excon.defaults[:connect_timeout] = 5
Excon.defaults[:write_timeout] = 120
Excon.defaults[:read_timeout] = 120

require_relative '../../lib/active_record/openstack'
require_relative '../../lib/authorization'

module OpenStackConnection
  def self.identity
    @@identity ||= Fog::Identity.new(OPENSTACK_ARGS)
  end

  def self.compute
    @@compute ||= Fog::Compute.new(OPENSTACK_ARGS)
  end
  
  def self.volume
    @@volume ||= Fog::Volume.new(OPENSTACK_ARGS)
  end
  
  def self.network
    @@network ||= Fog::Network.new(OPENSTACK_ARGS)
  end
  
  def self.image
    @@image ||= Fog::Image.new(OPENSTACK_ARGS)
  end
  
  def self.metering
    @@metering ||= Fog::Metering.new(OPENSTACK_ARGS)
  end

  def self.usage(from,to)
    Rails.cache.fetch("compute_usage_#{from.strftime("%Y%m%d")}_#{to.strftime("%Y%m%d")}", expires_in: 1.hour) do
      compute.list_usages(from, to, true).body['tenant_usages']
    end
  end
end