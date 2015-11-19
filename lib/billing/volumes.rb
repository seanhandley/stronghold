module Billing
  module Volumes

    def self.sync!(from, to, sync)
      Tenant.with_deleted.each do |tenant|
        next unless tenant.uuid
        Billing.fetch_samples(tenant.uuid, "volume", from, to).each do |volume_id, samples|
          create_new_states(tenant.uuid, volume_id, samples, sync)
        end
      end
    end

    def self.usage(tenant_id, from, to)
      volumes = Billing::Volume.where(:tenant_id => tenant_id).to_a.compact.reject{|volume| volume.deleted_at && volume.deleted_at < from}
      volumes = volumes.collect do |volume|
        tb_hours = terabyte_hours(volume, from, to)
        { terabyte_hours: tb_hours,
                                    cost: (tb_hours * RateCard.block_storage).nearest_penny,
                                    id: volume.volume_id,
                                    created_at: volume.created_at,
                                    deleted_at: volume.deleted_at,
                                    latest_size: volume.latest_size,
                                    name: volume.name}
      end
      volumes.select{|v| v[:terabyte_hours] > 0}
    end

    def self.terabyte_hours(volume, from, to)
      states = volume.volume_states.where(:recorded_at => from..to).order('recorded_at')
      previous_state = volume.volume_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first

      if states.any?
        if states.count > 1
          start = 0

          if previous_state
            if billable?(previous_state.event_name)
              start = seconds_to_whole_hours(states.first.recorded_at - from)
              start *= gigabytes_to_terabytes(states.first.size)
            end
          end

          previous = states.first
          middle = states.collect do |state|
            difference = 0
            if billable?(previous.event_name)
              difference = seconds_to_whole_hours(state.recorded_at - previous.recorded_at)
              difference *= gigabytes_to_terabytes(state.size)
            end
            previous = state
            difference
          end.sum

          ending = 0

          if(billable?(states.last.event_name))
            ending = seconds_to_whole_hours(to - states.last.recorded_at)
            ending *= gigabytes_to_terabytes(states.last.size)
          end

          return (start + middle + ending).round(2)
        else
          # Only one sample for this period
          if billable?(states.first.event_name)
            return (seconds_to_whole_hours(to - from) * gigabytes_to_terabytes(states.first.size)).round(2)
          else
            return 0
          end
        end
      else
        if previous_state && billable?(previous_state.event_name)
          return (seconds_to_whole_hours(to - from) * gigabytes_to_terabytes(previous_state.size)).round(2)
        else
          return 0
        end
      end
    end

    def self.billable?(event)
      event != 'volume.delete.end'
    end

    def self.seconds_to_whole_hours(seconds)
      (seconds / Billing::SECONDS_TO_HOURS).ceil
    end

    def self.gigabytes_to_terabytes(gigabytes)
      (gigabytes / 1024.0).round(2)
    end

    def self.create_new_states(tenant_id, volume_id, samples, sync)
      first_sample_metadata = samples.first['resource_metadata']
      unless Billing::Volume.find_by_volume_id(volume_id)
        volume = Billing::Volume.create(volume_id: volume_id, tenant_id: tenant_id, name: first_sample_metadata["display_name"])
        unless samples.any? {|s| s['resource_metadata']['event_type']}
          # This is a new volume and we don't know its current size
          # Attempt to find out
          if(os_volume = OpenStackConnection.volume.volumes.get(volume_id))
            volume.volume_states.create recorded_at: Time.now, size: os_volume.size,
                                            event_name: 'ping', billing_sync: sync,
                                            message_id: SecureRandom.uuid
          end
        end
      end
      billing_volume = Billing::Volume.find_by_volume_id(volume_id)

      # Catch renames
      if(billing_volume.name != first_sample_metadata["display_name"])
        billing_volume.update_attributes(name: first_sample_metadata["display_name"])
      end

      samples.collect do |s|
        if s['resource_metadata']['event_type']
          Billing::VolumeState.create volume_id: billing_volume.id, recorded_at: Time.zone.parse("#{s['recorded_at']} UTC"),
                                      size: s['resource_metadata']['size'],
                                      event_name: s['resource_metadata']['event_type'], billing_sync: sync,
                                      message_id: s['message_id']
        end
      end
    end

  end
end
