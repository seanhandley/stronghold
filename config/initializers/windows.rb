settings                = YAML.load_file("#{Rails.root}/config/windows.yml")[Rails.env]
BILLABLE_WINDOWS_PRICES = settings['prices']
BILLABLE_METADATA       = settings['metadata']

module Windows
  def self.billable?(instance)
    os = instance.metadata&.fetch('os') { nil }
    if os
      metadata['os'].include?(os)
    else
      false
    end
  end

  def self.rate_for(instance_flavor)
    prices[instance_flavor]['rate']
  end

  def self.metadata
    BILLABLE_METADATA
  end

  def self.prices
    BILLABLE_WINDOWS_PRICES
  end
end