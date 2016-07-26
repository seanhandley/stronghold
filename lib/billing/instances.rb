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
        billable_seconds = instance.billable_seconds ? instance.billable_seconds : seconds(instance, from, to)
        instance.update_attributes(billable_seconds: billable_seconds) if instance.terminated_at
        billable_hours = (billable_seconds / Billing::SECONDS_TO_HOURS).ceil
        instance_flavor = instance.instance_flavor
        cost = instance.cost ? instance.cost : cost(instance, from, to).nearest_penny
        instance.update_attributes(cost: cost) if instance.terminated_at
        {
          uuid: instance.instance_id,
          name: instance.name,
          project_id: instance.project_id,
          first_booted_at: instance.first_booted_at,
          latest_state: instance.latest_state(from,to),
          terminated_at: instance.terminated_at,
          billable_hours: billable_hours,
          resizes: instance.resizes(from, to),
          cost: cost,
          windows: Windows.billable?(instance),
          arch: instance.arch,
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
      instances.select{|instance| instance[:billable_hours] > 0}
    end

    def self.cost(instance, from, to)
      flavors = instance.fetch_states(from, to).collect(&:flavor_id)
      if flavors.uniq.count > 1
        return split_cost(instance, from, to).nearest_penny
      else
        billable_seconds = seconds(instance, from, to)
        billable_hours   = (billable_seconds / Billing::SECONDS_TO_HOURS).ceil
        base = (billable_hours * instance.rate.to_f)
        if Windows.billable?(instance)
          base += (billable_hours * Windows.rate_for(instance.flavor_id))
        end
        return base.nearest_penny
      end
    end

    def self.split_cost(instance, from, to)
      states = instance.fetch_states(from, to)
      previous_state = instance.instance_states.where('recorded_at < ?', from).order('recorded_at DESC').limit(1).first
      first_state = states.first
      last_state = states.last
      arch = instance.arch

      if states.any?
        if states.count > 1
          start = 0

          if previous_state
            if billable?(previous_state.state)
              start = (first_state.recorded_at - from)
              start = start / Billing::SECONDS_TO_HOURS
              base = start * previous_state.rate(arch)
              if Windows.billable?(instance)
                base += (start * Windows.rate_for(instance.flavor_id))
              end
              start = base
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
              base = difference * previous.rate(arch)
              if Windows.billable?(instance)
                base += (difference * Windows.rate_for(instance.flavor_id))
              end
              base
            ensure
              previous = state
            end
          end.sum

          ending = 0

          if(billable?(last_state.state))
            ending = (to - last_state.recorded_at)
            ending = ending / Billing::SECONDS_TO_HOURS
            base = ending * last_state.rate(arch)
            if Windows.billable?(instance)
              base += (ending * Windows.rate_for(instance.flavor_id))
            end
            ending = base
          end

          return (start + middle + ending)
        else
          # Only one sample for this period
          if billable?(first_state.state)
            time = (to - first_state.recorded_at)
            time = time / Billing::SECONDS_TO_HOURS
            base = time * first_state.rate(arch)
            if Windows.billable?(instance)
              base += (time * Windows.rate_for(instance.flavor_id))
            end
            return base
          else
            return 0
          end
        end
      else
        if previous_state && billable?(previous_state.state)
          time = (to - from)
          time = time / Billing::SECONDS_TO_HOURS
          base = time * previous_state.rate(arch)
          if Windows.billable?(instance)
            base += (time * Windows.rate_for(instance.flavor_id))
          end
          return base
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
          time = 0
          # Only one sample for this period
          if billable?(first_state.state)
            time += (to - first_state.recorded_at).round
          end
          if previous_state && billable?(previous_state.state)
            time += (first_state.recorded_at - from).round
          end
          return time
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
      !["error","building", "stopped", "suspended", "shutoff", "deleted", "resized"].include?(state.downcase)
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
            instance.instance_states.create recorded_at: Time.now, state: os_instance.state.downcase,
                                            event_name: 'ping', billing_sync: sync,
                                            message_id: SecureRandom.uuid
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
        if meta_data['event_type']
          Billing::InstanceState.create instance_id: billing_instance.id, recorded_at: Time.zone.parse("#{sample['recorded_at']} UTC"),
                                        state: meta_data['state'] ? meta_data['state'].downcase : 'active',
                                        event_name: meta_data['event_type'], billing_sync: sync,
                                        message_id: sample['message_id'],
                                        flavor_id: meta_data["instance_flavor_id"]
        end
      end
      instance.complete!
    end

  end
end
