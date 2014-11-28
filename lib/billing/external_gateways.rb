module Billing
  module ExternalGateways

    def self.sync!(from, to, sync)
      Tenant.all.each do |tenant|
        fetch_router_samples(tenant.uuid, from, to).each do |ip_id, samples|
          create_new_states(ip_id, samples, sync)
        end
      end
    end

    def self.usage(tenant_id, from, to)
      ips = Billing::ExternalGateway.where(:tenant_id => tenant_id).to_a.compact
      total = ips.inject({}) do |usage, ip|
        usage[ip.ip_id] = { billable_seconds: seconds(ip, from, to),
                                     address: ip.address}
        usage
      end
      total.select{|k,v| v[:billable_seconds] > 0}
    end

    def self.seconds(ip, from, to)
      states = ip.ip_states.where(:recorded_at => from..to).order('recorded_at')
      previous_state = ip.ip_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first

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
            return (to - from).round
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
      state.port.downcase != 'none'
    end

    def self.create_new_states(ip_id, samples, sync)
      first_sample_metadata = samples.first['resource_metadata']
      unless Billing::ExternalGateway.find_by_ip_id(ip_id)
        ip = Billing::ExternalGateway.create(ip_id: ip_id, tenant_id: first_sample_metadata['tenant_id'],
                                        address: samples.first['inferred_address'])
      end
      if(billing_ip = Billing::ExternalGateway.find_by_ip_id(ip_id))
        samples.collect do |s|
          if s['resource_metadata']['event_type']
            Billing::ExternalGatewayState.create ip_id: billing_ip.id, recorded_at: s['recorded_at'],
                                        port: s['resource_metadata']['external_gateway_info.network_id'],
                                        event_name: s['resource_metadata']['event_type'], billing_sync: sync,
                                        message_id: s['message_id']
          end
        end
      end
    end

    def self.fetch_port_samples(from, to)
      ext_nets    = Fog::Network.new(OPENSTACK_ARGS).networks.select{|n| n.router_external == true}.collect(&:id)
      ext_subnets = Fog::Network.new(OPENSTACK_ARGS).subnets.select{|s| ext_nets.include?(s.network_id)}.collect(&:id)
      timestamp_format = "%Y-%m-%dT%H:%M:%S"
      options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.strftime(timestamp_format)},
                 {'field' => 'timestamp', 'op' => 'lt', 'value' => to.strftime(timestamp_format)}]
      tenant_samples = Fog::Metering.new(OPENSTACK_ARGS).get_samples("port", options).body
      tenant_samples.select do |p|
        p['resource_metadata']['device_id'].present? &&
        ext_nets.include?(p['resource_metadata']['network_id'])
      end
    end

    def self.fetch_router_samples(tenant_id, from, to)
      timestamp_format = "%Y-%m-%dT%H:%M:%S"
      options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.strftime(timestamp_format)},
                 {'field' => 'timestamp', 'op' => 'lt', 'value' => to.strftime(timestamp_format)},
                 {'field' => 'project_id', 'op' => 'eq', 'value' => tenant_id}]
      tenant_samples = Fog::Metering.new(OPENSTACK_ARGS).get_samples("router", options).body

      ips = fetch_port_samples(from, to).inject({}) do |acc, sample|
        acc[sample['resource_metadata']['device_id']] = extract_address(sample)
        acc
      end

      tenant_samples = tenant_samples.collect{|s| s.merge('inferred_address' => ips[s['resource_id']]) }
      puts tenant_samples.inspect

      tenant_samples.group_by{|s| s['resource_id']}
    end

    def self.extract_address(data)
      data = data['resource_metadata']["fixed_ips"].gsub!("u'","'").gsub!("'","\"")
      JSON.parse(data[2...-2])['ip_address']
    end

  end
end
