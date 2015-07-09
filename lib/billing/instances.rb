module Billing
  module Instances

    def self.sync!(from, to, sync)
      Tenant.all.each do |tenant|
        next unless tenant.uuid
        Billing.fetch_samples(tenant.uuid, "instance", from, to).each do |instance_id, samples|
          create_new_states(tenant.uuid, instance_id, samples, sync)
        end
      end
    end

    def self.usage(tenant_id, from, to)
      instances = Billing::Instance.where(:tenant_id => tenant_id).to_a.compact
      instances = instances.collect do |instance|
        {billable_seconds: seconds(instance, from, to),
                                       uuid: instance.instance_id,
                                       name: instance.name,
                                       first_booted_at: instance.first_booted_at,
                                       latest_state: instance.latest_state(from,to),
                                       terminated_at: instance.terminated_at,
                                       flavor: {
                                         flavor_id: instance.flavor_id,
                                         name: instance.instance_flavor.name,
                                         vcpus_count: instance.instance_flavor.vcpus,
                                         ram_mb: instance.instance_flavor.ram,
                                         root_disk_gb: instance.instance_flavor.disk,
                                         rate: instance.instance_flavor.rate},
                                       image_id: instance.image_id}
      end
      instances.select{|i| i[:billable_seconds] > 0}
    end

    def self.seconds(instance, from, to)
      states = instance.instance_states.where(:recorded_at => from..to).order('recorded_at')
      previous_state = instance.instance_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first

      if states.any?
        if states.count > 1
          start = 0

          if previous_state
            if billable?(previous_state.state)
              start = (states.first.recorded_at - from)
            end
          end

          previous = states.first
          middle = states.collect do |state|
            difference = 0
            if billable?(previous.state)
              difference = state.recorded_at - previous.recorded_at
            end
            previous = state
            difference
          end.sum

          ending = 0

          if(billable?(states.last.state))
            ending = (to - states.last.recorded_at)
          end

          return (start + middle + ending).round
        else
          # Only one sample for this period
          if billable?(states.first.state)
            return (to - states.first.recorded_at).round
          else
            return 0
          end
        end
      else
        if previous_state && billable?(previous_state.state)
          return (to - from).round
        else
          return 0
        end
      end
    end

    def self.billable?(state)
      !["error","building", "stopped", "suspended", "shutoff", "deleted"].include?(state.downcase)
    end

    def self.create_new_states(tenant_id, instance_id, samples, sync)
      first_sample_metadata = samples.first['resource_metadata']
      flavor_id = first_sample_metadata["instance_flavor_id"] ? first_sample_metadata["instance_flavor_id"] : first_sample_metadata["flavor.id"]
      unless Billing::Instance.find_by_instance_id(instance_id)
        instance = Billing::Instance.create(instance_id: instance_id, tenant_id: tenant_id, name: first_sample_metadata["display_name"],
                                 flavor_id: flavor_id, image_id: first_sample_metadata["image_ref_url"].split('/').last)
        unless samples.any? {|s| s['resource_metadata']['event_type']}
          # This is a new instance and we don't know its current state.
          # Attempt to find out
          if(os_instance = Fog::Compute.new(OPENSTACK_ARGS).servers.get(instance_id))
            instance.instance_states.create recorded_at: DateTime.now, state: os_instance.state.downcase,
                                            event_name: 'ping', billing_sync: sync,
                                            message_id: SecureRandom.hex
          end
        end
      end
      unless Billing::InstanceFlavor.find_by_flavor_id(flavor_id)
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
      billing_instance = Billing::Instance.find_by_instance_id(instance_id)
      
      # Catch renames
      if(billing_instance.name != first_sample_metadata["display_name"])
        billing_instance.update_attributes(name: first_sample_metadata["display_name"])
      end

      samples.collect do |s|
        if s['resource_metadata']['event_type']
          Billing::InstanceState.create instance_id: billing_instance.id, recorded_at: Time.zone.parse("#{s['recorded_at']} UTC"),
                                        state: s['resource_metadata']['state'] ? s['resource_metadata']['state'].downcase : 'active',
                                        event_name: s['resource_metadata']['event_type'], billing_sync: sync,
                                        message_id: s['message_id']
          unless billing_instance.arch.present? || s['resource_metadata']['architecture'].empty?
            billing_instance.update_attributes(arch: s['resource_metadata']['architecture'])
          end
        end
      end
    end

  end
end
