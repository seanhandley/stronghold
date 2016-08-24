settings = YAML.load_file("#{Rails.root}/config/docker.yml")[Rails.env]

DOCKER_ARGS = {
  :auth_url               => settings['auth_url'],
  :openstack_client_image => settings['openstack_client_image']
}
