module Billing
  module FloatingIps

    def self.sync!(from, to)
      Tenant.all.each do |tenant|
        next unless tenant.uuid
        Billing.fetch_samples(tenant.uuid, "ip.floating", from, to).each do |ip_id, samples|
          create_new_states(tenant.uuid, ip_id, samples)
        end
      end
    end

    def self.usage(tenant_id, from, to)
      ips = Billing::FloatingIp.where(:tenant_id => tenant_id).to_a.compact
      total = ips.inject({}) do |usage, ip|
        usage[ip.floating_ip_id] = { billable_seconds: seconds(ip, from, to),
                                     address: ip.address}
        usage
      end
      total.select{|k,v| v[:billable_seconds] > 0}
    end

    def self.seconds(ip, from, to)
      states = ip.floating_ip_states.where(:recorded_at => from..to).order('recorded_at')
      previous_state = ip.floating_ip_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first

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

    def self.create_new_states(tenant_id, ip_id, samples)
      first_sample_metadata = samples.first['resource_metadata']
      unless Billing::FloatingIp.find_by_floating_ip_id(ip_id)
        ip = Billing::FloatingIp.create(floating_ip_id: ip_id, tenant_id: tenant_id,
                                        address: first_sample_metadata["floating_ip_address"])
        unless samples.any? {|s| s['resource_metadata']['event_type']}
          # This is a new volume and we don't know its current size
          # Attempt to find out
          if(os_volume = Fog::Network.new(OPENSTACK_ARGS).floating_ips.get(ip_id))
            ip.floating_ip_states.create recorded_at: DateTime.now, port: os_volume.port_id,
                                         event_name: 'ping'
          end
        end
      end
      billing_floating_ip_id = Billing::FloatingIp.find_by_floating_ip_id(ip_id).id
      samples.collect do |s|
        if s['resource_metadata']['event_type']
          Billing::FloatingIpState.create floating_ip_id: billing_floating_ip_id, recorded_at: s['recorded_at'],
                                      port: s['resource_metadata']['port_id'],
                                      event_name: s['resource_metadata']['event_type']
        end
      end
    end

  end
end
