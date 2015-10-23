module Billing
  module FloatingIps

    def self.sync!(from, to, sync)
      Tenant.all.each do |tenant|
        tenant_uuid = tenant.uuid
        next unless tenant_uuid
        Billing.fetch_samples(tenant_uuid, "ip.floating", from, to).each do |ip_id, samples|
          create_new_states(tenant_uuid, ip_id, samples, sync)
        end
      end
    end

    def self.usage(tenant_id, from, to)
      ips = Billing::Ip.where(:tenant_id => tenant_id).includes(:ip_states).to_a.compact
      quota = OpenStackConnection.network.get_quota(tenant_id).body['quota']['floatingip']
      total = ips.inject({}) do |usage, ip|
        usage[ip.ip_id] = { billable_seconds: seconds(ip, from, to),
                                     address: ip.address,
                                     quota: quota}
        usage
      end
      total.select{|_,value| value[:billable_seconds] > 0}
    end

    def self.seconds(ip, from, to)
      states = ip.ip_states.where(:recorded_at => from..to).order('recorded_at')
      previous_state = ip.ip_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first
      first_state = states.first
      last_state = states.last

      if states.any?
        if states.count > 1
          start = 0

          if previous_state
            if billable?(previous_state)
              start = (first_state.recorded_at - from)
            end
          end

          previous = first_state
          middle = states.collect do |state|
            difference = 0
            if billable?(previous)
              difference = state.recorded_at - previous.recorded_at
            end
            previous = state
            difference
          end.sum

          ending = 0

          if(billable?(last_state))
            ending = (to - last_state.recorded_at)
          end

          return (start + middle + ending).round
        else
          # Only one sample for this period
          if billable?(first_state)
            return (to - first_state.recorded_at).round
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
      state.port != "None"
    end

    def self.create_new_states(tenant_id, ip_id, samples, sync)
      first_sample_metadata = samples.first['resource_metadata']
      unless Billing::Ip.find_by_ip_id(ip_id)
        ip = Billing::Ip.create(ip_id: ip_id, tenant_id: tenant_id,
                                        address: first_sample_metadata["floating_ip_address"])
        unless samples.any? {|sample| sample['resource_metadata']['event_type']}
          # This is a new volume and we don't know its current size
          # Attempt to find out
          if(os_ip = OpenStackConnection.network.ips.get(ip_id))
            ip.ip_states.create recorded_at: Time.now, port: os_ip.port_id,
                                         event_name: 'ping', billing_sync: sync,
                                         message_id: SecureRandom.hex
          end
        end
      end
      billing_ip_id = Billing::Ip.find_by_ip_id(ip_id).id
      samples.collect do |sample|
        meta_data = sample['resource_metadata']
        if meta_data['event_type']
          Billing::IpState.create ip_id: billing_ip_id, recorded_at: Time.zone.parse("#{sample['recorded_at']} UTC"),
                                      port: meta_data['port_id'],
                                      event_name: meta_data['event_type'], billing_sync: sync,
                                      message_id: sample['message_id']
        end
      end
    end

  end
end
