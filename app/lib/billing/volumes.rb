module Billing
  module Volumes

    def self.sync!(from, to, sync)
      Rails.cache.delete('all_recorded_volume_ids')
      Project.with_deleted.each do |project|
        next unless project.uuid
        Billing.fetch_samples(project.uuid, "volume", from, to).each do |volume_id, samples|
          create_new_states(project.uuid, volume_id, samples, sync)
        end
      end
    end

    def self.usage(project_id, from, to)
      volumes = Billing::Volume.where("project_id = ? AND (deleted_at is null or deleted_at >= ?)", project_id, from)
      volumes = volumes.collect do |volume|
        {
          terabyte_hours: terabyte_hours(volume, from, to),
          cost: cost(volume, from, to).nearest_penny,
          id: volume.volume_id,
          created_at: volume.created_at,
          deleted_at: volume.deleted_at,
          latest_size: volume.latest_size,
          name: volume.name,
          ssd: volume.ssd?,
          tags: [
            volume.ssd? ? 'ssd' : nil,
          ].compact,
          volume_type_name: volume_name[volume.volume_type],
          owner: volume.volume_states&.first&.user_id
        }
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

    def self.cost(volume, from, to)
      volume_states = volume.volume_states.where(:recorded_at => from..to).order('recorded_at')
      rate = volume.ssd? ? RateCard.ssd_storage : RateCard.block_storage
      if volume_states.collect(&:volume_type).uniq.count > 1
        return split_cost(volume, volume_states, from, to).nearest_penny
      else
        tb_hours = terabyte_hours(volume, from, to)
        return (tb_hours * rate).nearest_penny
      end
    end

    def self.split_cost(volume, states, from, to)
      previous_state = volume.volume_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first
      first_state = states.first
      last_state = states.last

      if states.any?
        if states.count > 1
          start = 0

          if previous_state
            if billable?(previous_state.event_name)
              start = (first_state.recorded_at - from)
              start = start / Billing::SECONDS_TO_HOURS
              base = start * previous_state.rate
              start = base
            end
          end

          previous = states.first
          middle = states.collect do |state|
            difference = 0
            if billable?(previous.event_name)
              difference = state.recorded_at - previous.recorded_at
            end
            begin
              difference = difference / Billing::SECONDS_TO_HOURS
              base = difference * previous.rate
              base
            ensure
              previous = state
            end
          end.sum

          ending = 0

          if(billable?(last_state.event_name))
            ending = (to - last_state.recorded_at)
            ending = ending / Billing::SECONDS_TO_HOURS
            base = ending * last_state.rate
            ending = base
          end

          return (start + middle + ending)
        else
          # Only one sample for this period
          if billable?(first_state.event_name)
            time = (to - first_state.recorded_at)
            time = time / Billing::SECONDS_TO_HOURS
            base = time * first_state.rate
            return base
          else
            return 0
          end
        end
      else
        if previous_state && billable?(previous_state.event_name)
          time = (to - from)
          time = time / Billing::SECONDS_TO_HOURS
          base = time * previous_state.rate
          return base
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

    def self.volume_name
      {
        '176419cf-21f3-459d-882b-660e884f8cf1' => 'Ceph SSD',
        '965716f4-7fcb-441d-b2aa-ad48f44b41b7' => 'Ceph'
      }
    end

    def self.cached_volumes
      Rails.cache.fetch('all_recorded_volume_ids', expires_in: 5.minutes) do
        Billing::Volume.active.pluck(:id, :volume_id, :name).inject({}) do |hash, e|
          hash[e[1]] = {id: e[0], name: e[2]}
          hash
        end
      end
    end

    def self.create_new_states(project_id, volume_id, samples, sync)
      first_sample_metadata = samples.first['resource_metadata']
      unless cached_volumes.keys.include?(volume_id)
        Rails.cache.delete('all_recorded_volume_ids')
        volume = Billing::Volume.create(volume_id: volume_id, project_id: project_id,
                                        name: first_sample_metadata["display_name"])
        unless samples.any? {|s| s['resource_metadata']['event_type']}
          # This is a new volume and we don't know its current size
          # Attempt to find out
          if(os_volume = OpenStackConnection.volume.volumes.get(volume_id))
            volume.volume_states.create recorded_at: Time.now, size: os_volume.size,
                                            event_name: 'ping', billing_sync: sync,
                                            message_id: SecureRandom.uuid,
                                            volume_type: volume_name.key(os_volume.volume_type)
          end
        end
      end

      # Catch renames
      cached_volume = cached_volumes[volume_id]
      unless cached_volume
        v = Billing::Volume.find_by_volume_id(volume_id)
        cached_volume = {
          id: v.id,
          name: v.name
        }
      end
      if(cached_volume[:name] != first_sample_metadata["display_name"])
        billing_volume = Billing::Volume.find_by_volume_id(volume_id)
        billing_volume.update_attributes(name: first_sample_metadata["display_name"])
      end

      samples.collect do |s|
        if s['resource_metadata']['event_type']
          Billing::VolumeState.create volume_id: cached_volume[:id], recorded_at: Time.zone.parse("#{s['recorded_at']} UTC"),
                                      size: s['resource_metadata']['size'],
                                      event_name: s['resource_metadata']['event_type'], billing_sync: sync,
                                      message_id: s['message_id'],
                                      volume_type: s['resource_metadata']['volume_type'],
                                      user_id: s['user_id']
        end
      end
    end

  end
end
