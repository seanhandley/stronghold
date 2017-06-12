module Billing
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
        cost_by_flavour = instance.cost_by_flavor(from, to)
        instance_usage = instance.billable_hours(from, to).map do |flavor_id, hours|
          instance_flavor = Billing::InstanceFlavor.find_by_flavor_id flavor_id
          {
            unit: 'hours',
            value: hours,
            cost: {
              currency: 'gbp',
              value: cost_by_flavour[flavor_id].nearest_penny.round(2),
              rate: instance.rate_for_flavor(flavor_id)
            },
            meta: {
              flavor: {
                id: instance_flavor.flavor_id,
                name: instance_flavor.name,
                vcpus_count: instance_flavor.vcpus,
                ram_mb: instance_flavor.ram,
                root_disk_gb: instance_flavor.disk
              }
            }
          }
        end
        instance_flavor = instance.instance_flavor
        {
          id: instance.instance_id,
          name: instance.name,
          first_booted_at: instance.first_booted_at,
          latest_state: instance.latest_state(from,to),
          terminated_at: instance.terminated_at,
          history: instance.history(from, to),
          tags: [
            Windows.billable?(instance) ? "windows" : nil
          ].compact,
          current_flavor: {
            id: instance_flavor.flavor_id,
            name: instance_flavor.name,
            vcpus_count: instance_flavor.vcpus,
            ram_mb: instance_flavor.ram,
            root_disk_gb: instance_flavor.disk
          },
          usage: instance_usage
        }
      end
    end

    def self.cached_flavor_ids
      Rails.cache.fetch('instance_flavor_ids', expires_in: 5.minutes) do
        Billing::InstanceFlavor.all.pluck(:flavor_id)
      end
    end

    def self.create_new_states(project_id, instance_id, samples, sync)
      samples.reject!{|s| s['resource_metadata']['event_type'] == "compute.instance.exists"}
      return unless samples.any?

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
