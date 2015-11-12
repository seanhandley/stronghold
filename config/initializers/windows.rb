settings = YAML.load_file("#{Rails.root}/config/windows.yml")[Rails.env]
BILLABLE_WINDOWS_IMAGES = settings['images']
BILLABLE_WINDOWS_PRICES = settings['prices']

module Windows
  def self.billable?(instance)
    billable_images.include? instance.image_id
  end

  def self.rate_for(instance_flavor)
    prices[instance_flavor]['rate']
  end

  def self.billable_images
    BILLABLE_WINDOWS_IMAGES
  end

  def self.prices
    BILLABLE_WINDOWS_PRICES
  end
end