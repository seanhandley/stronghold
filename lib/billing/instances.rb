module Billing
  module Instances

    def self.sync!(from, to, sync)
      Tenant.all.each do |tenant|
        tenant_uuid = tenant.uuid
        next unless tenant_uuid
        Billing.fetch_samples(tenant_uuid, "instance", from, to).each do |instance_id, samples|
          create_new_states(tenant_uuid, instance_id, samples, sync)
        end
      end
    end

    def self.usage(tenant_id, from, to)
      instances = []
      if tenant_id.present?
        instances = Billing::Instance.where(:tenant_id => tenant_id).to_a.compact.reject{|instance| instance.terminated_at && instance.terminated_at < from}
      else
        instances = Billing::Instance.all.to_a.compact.reject{|instance| instance.terminated_at && instance.terminated_at < from}
      end
      instances = instances.collect do |instance|
        billable_seconds = seconds(instance, from, to)
        billable_hours = (billable_seconds / Billing::SECONDS_TO_HOURS).ceil
        instance_flavor = instance.instance_flavor
        {billable_seconds: billable_seconds,
                                       uuid: instance.instance_id,
                                       name: instance.name,
                                       tenant_id: instance.tenant_id,
                                       first_booted_at: instance.first_booted_at,
                                       latest_state: instance.latest_state(from,to),
                                       terminated_at: instance.terminated_at,
                                       rate: instance.rate,
                                       billable_hours: billable_hours,
                                       cost: cost(instance, from, to),
                                       arch: instance.arch,
                                       flavor: {
                                         flavor_id: instance.flavor_id,
                                         name: instance_flavor.name,
                                         vcpus_count: instance_flavor.vcpus,
                                         ram_mb: instance_flavor.ram,
                                         root_disk_gb: instance_flavor.disk,
                                         rate: instance_flavor.rate},
                                       image: {
                                         image_id: instance.image_id,
                                         name: instance.instance_image ? instance.instance_image.name : ''}
                                       }
      end
      instances.select{|instance| instance[:billable_seconds] > 0}
    end

    def self.cost(instance, from, to)
      flavors = instance.fetch_states(from, to).collect(&:flavor_id)
      if flavors.uniq.count > 1
        return split_cost(instance, from, to).nearest_penny
      else
        billable_seconds = seconds(instance, from, to)
        billable_hours   = (billable_seconds / Billing::SECONDS_TO_HOURS).ceil
        return (billable_hours * instance.rate.to_f).nearest_penny
      end
    end

    def self.split_cost(instance, from, to)
      states = instance.fetch_states(from, to)
      previous_state = instance.instance_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first
      first_state = states.first
      last_state = states.last

      if states.any?
        if states.count > 1
          start = 0

          if previous_state
            if billable?(previous_state.state)
              start = (first_state.recorded_at - from)
              start = start / Billing::SECONDS_TO_HOURS
              start * previous_state.rate
            end
          end

          previous = states.first
          middle = states.collect do |state|
            difference = 0
            if billable?(previous.state)
              difference = state.recorded_at - previous.recorded_at
            end
            begin
              difference = difference / Billing::SECONDS_TO_HOURS
              difference * previous.rate
            ensure
              previous = state
            end
          end.sum

          ending = 0

          if(billable?(last_state.state))
            ending = (to - last_state.recorded_at)
            ending = ending / Billing::SECONDS_TO_HOURS
            ending * last_state.rate
          end

          return (start + middle + ending)
        else
          # Only one sample for this period
          if billable?(first_state.state)
            time = (to - first_state.recorded_at)
            time = time / Billing::SECONDS_TO_HOURS
            return time * first_state.rate
          else
            return 0
          end
        end
      else
        if previous_state && billable?(previous_state.state)
          time = (to - from)
          time = time / Billing::SECONDS_TO_HOURS
          return time * previous_state.rate
        else
          return 0
        end
      end
    end

    def self.seconds(instance, from, to)
      states = instance.fetch_states(from, to)
      previous_state = instance.instance_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first
      first_state = states.first
      last_state = states.last

      if states.any?
        if states.count > 1
          start = 0

          if previous_state
            if billable?(previous_state.state)
              start = (first_state.recorded_at - from)
            end
          end

          previous = first_state
          middle = states.collect do |state|
            difference = 0
            if billable?(previous.state)
              difference = state.recorded_at - previous.recorded_at
            end
            previous = state
            difference
          end.sum

          ending = 0

          if(billable?(last_state.state))
            ending = (to - last_state.recorded_at)
          end

          return (start + middle + ending).round
        else
          # Only one sample for this period
          if billable?(first_state.state)
            return (to - first_state.recorded_at).round
          else
            return 0
          end
        end
      else
        if previous_state && billable?(previous_state.state) && instance.active?
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
        unless samples.any? {|sample| sample['resource_metadata']['event_type']}
          # This is a new instance and we don't know its current state.
          # Attempt to find out
          if(os_instance = OpenStackConnection.compute.servers.get(instance_id))
            instance.instance_states.create recorded_at: Time.now, state: os_instance.state.downcase,
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

      samples.collect do |sample|
        meta_data = sample['resource_metadata']
        if meta_data['event_type']
          Billing::InstanceState.create instance_id: billing_instance.id,
                                        recorded_at: Time.zone.parse("#{sample['recorded_at']} UTC"),
                                        timestamp: Time.zone.parse("#{sample['timestamp']} UTC"),
                                        state: meta_data['state'] ? meta_data['state'].downcase : 'active',
                                        event_name: meta_data['event_type'], billing_sync: sync,
                                        message_id: sample['message_id'],
                                        flavor_id: meta_data["instance_flavor_id"]
          unless meta_data['architecture'].empty? || meta_data['architecture'].downcase == 'none'
            billing_instance.update_attributes(arch: meta_data['architecture'])
          end
        end
      end
    end

  end
end
