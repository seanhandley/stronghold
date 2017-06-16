module Billing
  # This Instances module is responsible for  providing Instances info to the Billing Module.
  module Instances

    def self.sync!(from, to, sync)
      Rails.cache.delete('instance_flavor_ids')
      Project.with_deleted.each do |project|
        project_uuid = project.uuid
        next unless project_uuid
        Billing.fetch_samples(project_uuid, "instance", from, to).each do |instance_id, samples|
          create_new_states(project_uuid, instance_id, samples, sync)
        end
      end
    end

    def self.usage(project_id, from, to)
      instances = []
      if project_id.present?
        instances = Billing::Instance.where("project_id = ? AND (terminated_at is null or terminated_at >= ?) AND started_at < ?", project_id, from, to)
      else
        instances = Billing::Instance.where("(terminated_at is null or terminated_at >= ?) AND started_at < ?", from, to)
      end

      instances = instances.collect do |instance|
        instance_flavor = instance.instance_flavor

        {
          uuid: instance.instance_id,
          name: instance.name,
          project_id: instance.project_id,
          first_booted_at: instance.first_booted_at,
          latest_state: instance.latest_state(from,to),
          terminated_at: instance.terminated_at,
          billable_hours: instance.billable_hours(from, to),
          total_hours: instance.billable_hours(from, to).values.sum,
          history: instance.history(from, to),
          cost: instance.cost(from, to).nearest_penny,
          cost_by_flavor: instance.cost_by_flavor(from, to),
          windows: Windows.billable?(instance),
          tags: [
            Windows.billable?(instance) ? "windows" : nil
          ].compact,
          flavor: {
            flavor_id: instance_flavor.flavor_id,
            name: instance_flavor.name,
            vcpus_count: instance_flavor.vcpus,
            ram_mb: instance_flavor.ram,
            root_disk_gb: instance_flavor.disk,
            rate: instance_flavor.rate},
          image: {
            image_id: instance.image_id,
            name: instance.instance_image ? instance.instance_image.name : ''
          }
        }
      end
      instances.select{|instance| instance[:total_hours] != 0}
    end

    def self.cached_flavor_ids
      Rails.cache.fetch('instance_flavor_ids', expires_in: 5.minutes) do
        Billing::InstanceFlavor.all.pluck(:flavor_id)
      end
    end

    def self.create_new_states(project_id, instance_id, samples, sync)
      first_sample_metadata = samples.first['resource_metadata']
      flavor_id = first_sample_metadata["instance_flavor_id"] ? first_sample_metadata["instance_flavor_id"] : first_sample_metadata["flavor.id"]
      billing_instance = Billing::Instance.find_by_instance_id(instance_id)
      unless billing_instance
        billing_instance = Billing::Instance.find_or_create_by(instance_id: instance_id) do |instance|
          instance.project_id  = project_id
          instance.name        = first_sample_metadata["display_name"]
          instance.flavor_id   = flavor_id
          instance.image_id    = first_sample_metadata["image_ref_url"].split('/').last
        end
        unless samples.any? && samples.any? {|sample| sample['resource_metadata']['event_type']}
          # This is a new instance and we don't know its current state.
          # Attempt to find out
          if(os_instance = OpenStackConnection.compute.servers.get(instance_id))
            billing_instance.instance_states.create recorded_at: Time.now, state: os_instance.state.downcase,
                                            event_name: 'ping', billing_sync: sync,
                                            message_id: SecureRandom.uuid,
                                            flavor_id: os_instance.flavor['id']
          end
        end
      end
      unless cached_flavor_ids.include?(flavor_id)
        Rails.cache.delete('instance_flavor_ids')
        if(os_flavor = OpenStack::Flavor.find(flavor_id))
          Billing::InstanceFlavor.create(flavor_id: flavor_id, name: os_flavor.name,
                                         ram: os_flavor.ram, disk: os_flavor.disk, vcpus: os_flavor.vcpus)
        else
          Billing::InstanceFlavor.create(flavor_id: flavor_id, name: first_sample_metadata['flavor.name'],
                                         ram: first_sample_metadata['memory_mb'],
                                         disk: first_sample_metadata['root_gb'],
                                         vcpus: first_sample_metadata['vcpus'])
        end
      end

      # Catch renames
      if(billing_instance && first_sample_metadata && billing_instance.name != first_sample_metadata["display_name"])
        billing_instance.update_attributes(name: first_sample_metadata["display_name"])
      end

      samples.collect do |sample|
        meta_data = sample['resource_metadata']
        if meta_data['event_type'] && meta_data['event_type'] != "compute.instance.exists"
          Billing::InstanceState.create instance_id: billing_instance.id, recorded_at: Time.zone.parse("#{sample['recorded_at']} UTC"),
                                        state: meta_data['state'] ? meta_data['state'].downcase : 'active',
                                        event_name: meta_data['event_type'], billing_sync: sync,
                                        message_id: sample['message_id'],
                                        flavor_id: meta_data["instance_flavor_id"],
                                        user_id: sample['user_id']
        end
      end
      billing_instance.reindex_states
    end

  end
end
