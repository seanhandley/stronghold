settings = YAML.load_file("#{Rails.root}/config/ceph.yml")[Rails.env]

CEPH_ARGS = {
  :api_url    => settings['api_url'],
  :ceph_token => Rails.application.secrets.ceph_token,
  :ceph_key   => Rails.application.secrets.ceph_key
}
