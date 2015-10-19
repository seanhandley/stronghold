require_relative './config/environment'

require 'ruby-prof'

class Tenant < ActiveRecord::Base
  def quotas
      {
        "compute" => compute_quota,
        "volume"  => volume_quota,
        "network" => network_quota,
        "object_storage" => storage_quota
      }
  end
end

module Billing

  @@cache = {}

  def self.sync!
    now = Time.now
    from = Billing::Sync.last.started_at
    to   = now
    sync = Billing::Sync.create started_at: now
    Billing::Instances.sync!(from, to, sync)
    Billing::Volumes.sync!(from, to, sync)
    Billing::FloatingIps.sync!(from, to, sync)
    # Billing::IpQuotas.sync!(sync)
    Billing::ExternalGateways.sync!(from, to, sync)
    Billing::Images.sync!(from, to, sync)
    Billing::StorageObjects.sync!(sync)
    sync.destroy
  end

  def self.fetch_all_samples(measurement, from, to)
    key = "ceilometer_samples_#{measurement}_#{from.utc.strftime(timestamp_format)}_#{to.utc.strftime(timestamp_format)}"
    return @@cache[key] if @@cache[key]
    options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.utc.strftime(timestamp_format)},
               {'field' => 'timestamp', 'op' => 'lt', 'value' => to.utc.strftime(timestamp_format)}]
    tenant_samples = Fog::Metering.new(OPENSTACK_ARGS).get_samples(measurement, options).body
    @@cache[key] = tenant_samples.group_by{|s| s['project_id']}
    @@cache[key] 
  end
end

module Billing
  module ExternalGateways
    @@eg_cache = {}
    def self.fetch_router_samples(tenant_id, from, to)
      samples, ports = *fetch_all_router_samples_and_ports(from, to)
      tenant_samples = samples.select{|sample| sample['resource_metadata']['tenant_id'] == tenant_id}
      tenant_samples = tenant_samples.collect do |sample|
        gateways = ports.select{|port| port.device_id == sample['resource_id'] && port.device_owner == 'network:router_gateway'}
        address = gateways.any? ? gateways.first : nil
        if address
          sample.merge('inferred_address' => address.fixed_ips.first['ip_address'])
        end
        s
      end

      tenant_samples.compact.group_by{|sample| sample['resource_id']}
    end

    def self.fetch_all_router_samples_and_ports(from, to)
      timestamp_format = "%Y-%m-%dT%H:%M:%S"
      key = "ceilometer_samples_all_routers_#{from.utc.strftime(timestamp_format)}_#{to.utc.strftime(timestamp_format)}"
      return @@eg_cache[key] if @@eg_cache[key]
      options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.strftime(timestamp_format)},
                 {'field' => 'timestamp', 'op' => 'lt', 'value' => to.strftime(timestamp_format)}]
      samples = Fog::Metering.new(OPENSTACK_ARGS).get_samples("router", options).body
      ports = Fog::Network.new(OPENSTACK_ARGS).ports.all
      @@eg_cache[key] = [samples, ports]
      @@eg_cache[key]
    end
  end
end

# Profile the code
RubyProf.start

Billing.sync!

result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)