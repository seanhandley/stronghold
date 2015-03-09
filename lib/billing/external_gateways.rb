module Billing
  module ExternalGateways

    def self.sync!(from, to, sync)
      Tenant.all.each do |tenant|
        fetch_router_samples(tenant.uuid, from, to).each do |router_id, samples|
          create_new_states(router_id, samples, sync)
        end
      end
    end

    def self.usage(tenant_id, from, to)
      routers = Billing::ExternalGateway.where(:tenant_id => tenant_id).to_a.compact
      total = routers.inject({}) do |usage, router|
        usage[router.router_id] = { billable_seconds: seconds(router, from, to),
                                    id: router.router_id,
                                    name: router.name}
        usage
      end
      total.select{|k,v| v[:billable_seconds] > 0}
    end

    def self.seconds(router, from, to)
      states = router.external_gateway_states.where(:recorded_at => from..to).order('recorded_at')
      previous_state = router.external_gateway_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first

      if states.any?
        if states.count > 1
          start = 0

          if previous_state
            if billable?(previous_state)
              start = (states.first.recorded_at - from)
            end
          end

          previous = states.first
          middle = states.collect do |state|
            difference = 0
            if billable?(previous)
              difference = state.recorded_at - previous.recorded_at
            end
            previous = state
            difference
          end.sum

          ending = 0

          if(billable?(states.last))
            ending = (to - states.last.recorded_at)
          end

          return (start + middle + ending).round
        else
          # Only one sample for this period
          if billable?(states.first)
            return (to - states.first.recorded_at).round
          else
            return 0
          end
        end
      else
        if previous_state && billable?(previous_state)
          return (to - from).round
        else
          return 0
        end
      end
    end

    def self.billable?(state)
      state.external_network_id.present?
    end

    def self.create_new_states(router_id, samples, sync)
      first_sample_metadata = samples.first['resource_metadata']
      unless Billing::ExternalGateway.find_by_router_id(router_id)
        router = Billing::ExternalGateway.create(router_id: router_id, tenant_id: first_sample_metadata['tenant_id'],
                                                 name: first_sample_metadata['name'])
      end
      if(billing_external_gateway = Billing::ExternalGateway.find_by_router_id(router_id))
        samples.collect do |s|
          if s['resource_metadata']['event_type']
            Billing::ExternalGatewayState.create external_gateway_id: billing_external_gateway.id, recorded_at: s['recorded_at'],
                                        external_network_id: s['resource_metadata']['external_gateway_info.network_id'],
                                        event_name: s['resource_metadata']['event_type'], billing_sync: sync,
                                        message_id: s['message_id'], address: s['inferred_address']
          end
        end
      end
    end

    def self.fetch_router_samples(tenant_id, from, to)
      timestamp_format = "%Y-%m-%dT%H:%M:%S"
      options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.strftime(timestamp_format)},
                 {'field' => 'timestamp', 'op' => 'lt', 'value' => to.strftime(timestamp_format)}]
      tenant_samples = Fog::Metering.new(OPENSTACK_ARGS).get_samples("router", options).body
      tenant_samples = tenant_samples.select{|s| s['resource_metadata']['tenant_id'] == tenant_id}

      tenant_samples = tenant_samples.collect do |s|
        gateways = Fog::Network.new(OPENSTACK_ARGS).ports.all(device_id: s['resource_id'], device_owner: 'network:router_gateway')
        address = gateways.any? ? gateways.first : nil
        if address
          s.merge('inferred_address' => address.fixed_ips.first['ip_address'])
        end
        s
      end

      tenant_samples.compact.group_by{|s| s['resource_id']}
    end

  end
end
