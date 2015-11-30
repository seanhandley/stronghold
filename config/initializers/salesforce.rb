SALESFORCE_PRODUCT_MAPPINGS = YAML.load_file("#{Rails.root}/config/salesforce_products.yml")["salesforce_products"]

module Salesforce
  def self.find_instance_product(flavor_id, windows: false)
    key = windows ? 'windows_instances' : 'instances'
    SALESFORCE_PRODUCT_MAPPINGS[key].each do |_, instance|
      if instance['openstack_flavor'] == flavor_id
        return instance
      end
    end
    nil
  end
end

Restforce.configure do |config|
  # config.cache = Rails.cache
  config.api_version = "32.0"
end

require_relative '../../lib/active_record/salesforce'

SALESFORCE_CURRENCY_GBP = 'a0Jb000000ll9AHEAY'
SALESFORCE_OWNER_COMPANY = 'a0eb00000003NgzAAE'
