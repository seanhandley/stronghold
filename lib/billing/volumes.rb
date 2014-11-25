module Billing
  module Volumes

    def self.sync!(from, to)
      Tenant.all.each do |tenant|
        next unless tenant.uuid
        Billing.fetch_samples(tenant.uuid, "volume", from, to).each do |volume_id, samples|
          create_new_states(tenant.uuid, volume_id, samples)
        end
      end
    end

    def self.usage(tenant_id, from, to)
      volumes = Billing::Volume.where(:tenant_id => tenant_id).to_a.compact
      total = volumes.inject({}) do |usage, volume|
        usage[volume.volume_id] = { gigabyte_seconds: gigabyte_seconds(volume, from, to),
                                    name: volume.name}
        usage
      end
      total.select{|k,v| v[:gigabyte_seconds] > 0}
    end

    def self.gigabyte_seconds(volume, from, to)
      states = volume.volume_states.where(:recorded_at => from..to).order('recorded_at')
      previous_state = volume.volume_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first

      if states.any?
        if states.count > 1
          start = 0

          if previous_state
            if billable?(previous_state.event_name)
              start = (states.first.recorded_at - from)
              start *= states.first.size
            end
          end

          previous = states.first
          middle = states.collect do |state|
            difference = 0
            if billable?(previous.event_name)
              difference = state.recorded_at - previous.recorded_at
              difference *= state.size
            end
            previous = state
            difference
          end.sum

          ending = 0

          if(billable?(states.last.event_name))
            ending = (to - states.last.recorded_at)
            ending *= states.last.size
          end

          return (start + middle + ending).round
        else
          # Only one sample for this period
          if billable?(states.first.event_name)
            return ((to - from) * states.first.size).round
          else
            return 0
          end
        end
      else
        if previous_state && billable?(previous_state.event_name)
          return ((to - from) * previous_state.size).round
        else
          return 0
        end
      end
    end

    def self.billable?(event)
      event != 'volume.delete.end'
    end

    def self.create_new_states(tenant_id, volume_id, samples)
      first_sample_metadata = samples.first['resource_metadata']
      unless Billing::Volume.find_by_volume_id(volume_id)
        volume = Billing::Volume.create(volume_id: volume_id, tenant_id: tenant_id, name: first_sample_metadata["display_name"])
        unless samples.any? {|s| s['resource_metadata']['event_type']}
          # This is a new volume and we don't know its current size
          # Attempt to find out
          if(os_volume = Fog::Volume.new(OPENSTACK_ARGS).volumes.get(volume_id))
            volume.volume_states.create recorded_at: DateTime.now, size: os_volume.size,
                                            event_name: 'ping'
          end
        end
      end
      billing_volume_id = Billing::Volume.find_by_volume_id(volume_id).id
      samples.collect do |s|
        if s['resource_metadata']['event_type']
          Billing::VolumeState.create volume_id: billing_volume_id, recorded_at: s['recorded_at'],
                                      size: s['resource_metadata']['size'],
                                      event_name: s['resource_metadata']['event_type']
        end
      end
    end

  end
end
