settings = YAML.load_file("#{Rails.root}/config/dark_launch.yml")[Rails.env]
DARK_LAUNCH_SENSITIVE = settings['requires_dark_launch']

module DarkLaunch
  def self.hide?
    return false if Authorization.current_user.staff?
    DARK_LAUNCH_SENSITIVE
  end
end