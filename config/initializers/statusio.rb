settings = YAML.load_file("#{Rails.root}/config/statusio.yml")[Rails.env]

STATUS_IO_ARGS = {
  :host    => settings['url']
}