module Billing
  module FloatingIps

    def self.sync!(from, to, sync)
      Tenant.all.each do |tenant|
        next unless tenant.uuid
        Billing.fetch_samples(tenant.uuid, "ip.floating", from, to).each do |ip_id, samples|
          create_new_states(tenant.uuid, ip_id, samples, sync)
        end
        reap_old_floating_ips(sync)
      end
    end

    def self.usage(tenant_id, from, to)
      ips = Billing::Ip.where(:tenant_id => tenant_id).to_a.compact
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
      state.event_name != 'floatingip.destroy.end'
    end

    def self.create_new_states(tenant_id, ip_id, samples, sync)
      first_sample_metadata = samples.first['resource_metadata']
      unless Billing::Ip.find_by_ip_id(ip_id)
        ip = Billing::Ip.create(ip_id: ip_id, tenant_id: tenant_id,
                                        address: first_sample_metadata["floating_ip_address"])
        unless samples.any? {|s| s['resource_metadata']['event_type']}
          # This is a new volume and we don't know its current size
          # Attempt to find out
          if(os_ip = Fog::Network.new(OPENSTACK_ARGS).ips.get(ip_id))
            ip.ip_states.create recorded_at: DateTime.now, port: os_ip.port_id,
                                         event_name: 'ping', billing_sync: sync,
                                         message_id: SecureRandom.hex
          end
        end
      end
      billing_ip_id = Billing::Ip.find_by_ip_id(ip_id).id
      samples.collect do |s|
        if s['resource_metadata']['event_type']
          Billing::IpState.create ip_id: billing_ip_id, recorded_at: s['recorded_at'],
                                      port: s['resource_metadata']['port_id'],
                                      event_name: s['resource_metadata']['event_type'], billing_sync: sync,
                                      message_id: s['message_id']
        end
      end
    end

    def self.reap_old_floating_ips(sync)
      Billing::Ip.active.each do |ip|
        unless Fog::Network.new(OPENSTACK_ARGS).floating_ips.get(ip.ip_id)
          Billing::IpState.create ip_id: ip.id, recorded_at: Time.zone.now,
                                  port: 'None',
                                  event_name: 'floatingip.destroy.end', billing_sync: sync,
                                  message_id: SecureRandom.hex
          ip.update_attributes(active: false)
        end
      end
    end

  end
end
