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
        cost_by_volume_type = volume.cost_by_volume_type(from, to)
        volume_usage = volume.terabyte_hours(from, to).map do |volume_type, tbh|
          {
            unit: 'terabyte hours',
            value: tbh.nearest_penny.round(2),
            cost: {
              currency: 'gbp',
              value: cost_by_volume_type[volume_type].nearest_penny.round(2),
              rate: volume.rate_for_volume_type(volume_type)
            },
            meta: {
              volume_type: volume_name[volume_type]
            }
          }
        end
        {
          id: volume.volume_id,
          created_at: volume.created_at,
          deleted_at: volume.deleted_at,
          latest_size_gb: volume.latest_size,
          name: volume.name,
          tags: [
            volume.ssd? ? 'ssd' : nil,
          ].compact,
          owner: volume.volume_states&.first&.user_id,
          usage: volume_usage
        }
      end
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
      billing_volume = Billing::Volume.find_by_volume_id(volume_id)
      unless cached_volumes.keys.include?(volume_id)
        Rails.cache.delete('all_recorded_volume_ids')
        billing_volume = Billing::Volume.find_or_create_by(volume_id: volume_id) do |volume|
          volume.project_id = project_id
          volume.name       = first_sample_metadata["display_name"]
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
      billing_volume.reindex_states
    end
  end
end
