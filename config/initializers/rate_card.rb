module RateCard
  class << self
    def block_storage
      price('block_storage')
    end
    def object_storage
      price('object_storage')
    end
    def ssd_storage
      price('ssd_block_storage')
    end
    def ip_address
      price('ip_addresses')
    end
    def lb_pool
      price('load_balancer')
    end
    def vpn_connection
      price('vpn_connection')
    end

    private

    def price(key)
      product_id = SALESFORCE_PRODUCT_MAPPINGS[key]['salesforce_id']
      Salesforce::Product.all[product_id][:price]
    end
  end
end
