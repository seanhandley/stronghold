require 'fog/openstack'
require_relative "./excon"

module OpenStackConnection
  @@service_provider = 'datacentred'
  @@config_cache = {}

  def self.service_provider=(value)
    @@service_provider = value
  end

  def self.config_load
    YAML.load(ERB.new(File.read("#{Rails.root}/config/openstack.yml")).result)[@@service_provider][Rails.env]
  end

  # Loads configuration to be passed to an OpenStack client.
  # As we deal with multiple service providers these are organized
  # by service provider then environment.
  def self.configuration
    @@config_cache[@@service_provider] ||= config_load
  end

  def self.identity
    Fog::Identity.new(configuration)
  end

  def self.compute
    Fog::Compute.new(configuration)
  end
  
  def self.volume
    Fog::Volume.new(configuration)
  end
  
  def self.network
    Fog::Network.new(configuration)
  end
  
  def self.image
    Fog::Image.new(configuration)
  end
  
  def self.metering
    Fog::Metering.new(configuration)
  end

  def self.storage
    Fog::Storage.new(configuration)
  end

  def self.usage(from,to)
    Rails.cache.fetch("compute_usage_#{from.strftime("%Y%m%d")}_#{to.strftime("%Y%m%d")}", expires_in: 1.week) do
      compute.list_usages(from, to, true).body['tenant_usages']
    end
  end
end



## DIRTY MONKEY PATCH

OpenStackConnection.metering rescue nil

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
