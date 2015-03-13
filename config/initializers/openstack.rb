settings = YAML.load_file("#{Rails.root}/config/openstack.yml")[Rails.env]

OPENSTACK_ARGS = {
  :provider           => 'OpenStack',
  :openstack_auth_url => settings['auth_url'],
  :openstack_username => ENV["OPENSTACK_USERNAME"],
  :openstack_api_key  => ENV["OPENSTACK_PASSWORD"],
  :openstack_tenant   => ENV["OPENSTACK_TENANT"]
}

Excon.defaults[:write_timeout] = 30
Excon.defaults[:read_timeout] = 30

require_relative '../../lib/active_record/openstack'
require_relative '../../lib/authorization'
