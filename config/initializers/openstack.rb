settings = YAML.load_file("#{Rails.root}/config/openstack.yml")[Rails.env]

OPENSTACK_ARGS = {
  :provider           => 'OpenStack',
  :openstack_auth_url => settings['auth_url'],
  # These ENV vars will eventually be drawn from the User/Organisation data
  :openstack_username => ENV["OPENSTACK_USERNAME"],
  :openstack_api_key  => ENV["OPENSTACK_PASSWORD"],
  :openstack_tenant   => ENV["OPENSTACK_TENANT"]
}