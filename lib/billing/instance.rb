module Billing
  module Instance
    def self.samples(tenant_id, from, to)
      timestamp_format = "%Y-%m-%dT%H:%M:%S"
      options = [{'field' => 'timestamp', 'op' => 'ge', 'value' => from.strftime(timestamp_format)},
                 {'field' => 'timestamp', 'op' => 'lt', 'value' => to.strftime(timestamp_format)},
                 {'field' => 'project_id', 'value' => tenant_id, 'op' => 'eq'}]
      tenant_samples = Fog::Metering.new(OPENSTACK_ARGS).get_samples("instance", options).body
      tenant_samples.group_by{|s| s['resource_id']}
    end

    def self.new_state(instance_id, samples, previous_state = nil)
      example_state = {instance_id: 'foo', recorded_at: '2014-11-18 12:34:29', flavour: 1, image_id: 'bar', active: true}
      if previous_state
        # 
      else
        if instance = Fog::Compute.new(OPENSTACK_ARGS).servers.get(instance_id)
          # No previous state, and the given instance exists
          # Record its current state and associated info
          return {instance_id: instance.id, recorded_at: Time.now, flavor: instance.flavor['id'],
                  image: instance.image['id'], active: active?(instance.state) }
        else
          # No previous state, and the given instance doesn't currently exist
          # If it's been deleted, it should have a corresponding event in the batch of samples
        end
      end
    end

    def self.active?(state)
      state.upcase != 'SHUTOFF'
    end
    
  end
end
