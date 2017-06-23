require 'fog/openstack'

## DIRTY MONKEY PATCH
module Fog
  module Metering
    class OpenStack
      class Real
        def get_samples(meter_id, options = [])
          data = {
            'q' => []
          }

          options.each do |opt|
            filter = {}

            ['field', 'op', 'value'].each do |key|
              filter[key] = opt[key] if opt[key]
            end

            data['q'] << filter unless filter.empty?
            ## MAGIC
            data['limit'] = 10000000
          end

          request(
            :body    => Fog::JSON.encode(data),
            :expects => 200,
            :method  => 'GET',
            :path    => "meters/#{meter_id}"
          )
        end
      end
    end
  end
end
## DIRTY MONKEY PATCH


settings = YAML.load_file("#{Rails.root}/config/openstack.yml")[Rails.env]

OPENSTACK_ARGS = {
  :provider                        => 'OpenStack',
  :openstack_auth_url              => settings['auth_url'],
  :openstack_username              => ENV["OPENSTACK_USERNAME"],
  :openstack_api_key               => ENV["OPENSTACK_PASSWORD"],
  :openstack_project_name          => ENV["OPENSTACK_PROJECT_NAME"],
  :openstack_domain_id             => 'default',
  :persistent                      => true
}

Excon.defaults[:connect_timeout] = 10
Excon.defaults[:write_timeout] = 180
Excon.defaults[:read_timeout] = 180

module OpenStackConnection
  def self.identity
    Fog::Identity.new(OPENSTACK_ARGS)
  end

  def self.compute
    Fog::Compute.new(OPENSTACK_ARGS)
  end
  
  def self.volume
    Fog::Volume.new(OPENSTACK_ARGS)
  end
  
  def self.network
    Fog::Network.new(OPENSTACK_ARGS)
  end
  
  def self.image
    Fog::Image.new(OPENSTACK_ARGS)
  end
  
  def self.metering
    Fog::Metering.new(OPENSTACK_ARGS)
  end

  def self.storage
    Fog::Storage.new(OPENSTACK_ARGS)
  end

  def self.usage(from,to)
    Rails.cache.fetch("compute_usage_#{from.strftime("%Y%m%d")}_#{to.strftime("%Y%m%d")}", expires_in: 1.week) do
      compute.list_usages(from, to, true).body['tenant_usages']
    end
  end
end