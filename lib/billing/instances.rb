module Billing
  module Instances
    # example_instance = { id: 'foo', name: 'bar', flavor: 1, image_id: 'baz', tenant_id: 'qux'}
    # { flavor: instance.flavor['id'], image: instance.image['id'] }
    # example_state    = { instance_id: 'foo', recorded_at: '2014-11-18 12:34:29', active: true}

    def self.sync!
      ActiveRecord::Base.transaction do
        from = Billing::Sync.last.completed_at
        to   = DateTime.now
        Tenant.all.each do |tenant|
          fetch_samples(tenant.uuid, from, to).each do |instance_id, samples|
            create_new_states(tenant.uuid, instance_id, samples)
          end
        end
        Billing::Sync.create completed_at: DateTime.now
      end
    end

    def self.usage(tenant_id, from, to)
      active_instances = Billing::InstanceState.where(:recorded_at => from..to).to_a.collect{|state| state.billing_instance}.compact
      active_instances.inject({}) do |usage, instance|
        usage[instance.instance_id] = {billable_seconds: seconds(instance, from, to),
                                       name: instance.name, flavor_id: instance.flavor_id,
                                       image_id: instance.image_id}
        usage
      end
    end

    def self.seconds(instance, from, to)
      states = instance.instance_states.where(:recorded_at => from..to).order('recorded_at')
      previous = states.first
      states.collect do |state|
        difference = 0
        if billable?(previous.state)
          difference = state.recorded_at - previous.recorded_at
        end
        previous = state
        difference
      end.sum
    end

    def self.billable?(state)
      !["building", "stopped", "shutoff", "deleted"].include?(state.downcase)
    end

    def self.create_billing_instance_if_absent(tenant_id, instance_id)

    end

    def self.fetch_samples(tenant_id, from, to)
      timestamp_format = "%Y-%m-%dT%H:%M:%S"
      options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.strftime(timestamp_format)},
                 {'field' => 'timestamp', 'op' => 'lt', 'value' => to.strftime(timestamp_format)},
                 {'field' => 'project_id', 'value' => tenant_id, 'op' => 'eq'}]
      tenant_samples = Fog::Metering.new(OPENSTACK_ARGS).get_samples("instance", options).body
      tenant_samples.group_by{|s| s['resource_id']}
    end

    def self.create_new_states(tenant_id, instance_id, samples)
      unless Billing::Instance.find_by_instance_id(instance_id)
        first_sample_metadata = samples.first['resource_metadata']
        flavor_id = first_sample_metadata["instance_flavor_id"] ? first_sample_metadata["instance_flavor_id"] : first_sample_metadata["flavor.id"]
        Billing::Instance.create(instance_id: instance_id, tenant_id: tenant_id, name: first_sample_metadata["display_name"],
                                 flavor_id: flavor_id, image_id: first_sample_metadata["image_ref_url"].split('/').last)
      end
      billing_instance_id = Billing::Instance.find_by_instance_id(instance_id).id
      samples.collect do |s|
        Billing::InstanceState.create instance_id: billing_instance_id, recorded_at: s['recorded_at'],
                                      state: s['resource_metadata']['state'] ? s['resource_metadata']['state'].downcase : 'active' , message_id: s['message_id']
      end
    end

  end
end
