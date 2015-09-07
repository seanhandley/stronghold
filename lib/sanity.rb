module Sanity
  def self.check
    missing_instances = Billing::Instance.active.reject do |instance|
      if live_instances[instance.instance_id].nil?
        false
      else
        from = instance.instance_states.order('recorded_at').first.recorded_at
        to   = instance.instance_states.order('recorded_at').last.recorded_at
        check_instance_state(live_instances[instance.instance_id]['status'].downcase,
                   instance.fetch_states(from, to).last.state.downcase)
      end
    end

    new_instances = live_instances.reject do |instance,_|
      Billing::Instance.find_by_instance_id(instance) || instance_in_error_state(instance)
    end

    missing_volumes = Billing::Volume.active.reject do |volume|
      begin
        Fog::Volume.new(OPENSTACK_ARGS).get_volume_details(volume.volume_id)
      rescue Fog::Compute::OpenStack::NotFound
        false
      end
    end

    missing_images = Billing::Image.active.reject do |image|
      live_images.include? image.image_id
    end

    missing_routers = Billing::ExternalGateway.active.reject do |router|
      live_routers.include? router.router_id
    end

    results = {
      missing_instances: Hash[missing_instances.collect{|i| [i.instance_id, {name: i.name, tenant_id: i.tenant_id}]}],
      missing_volumes: Hash[missing_volumes.collect{|i| [i.volume_id, {name: i.name, tenant_id: i.tenant_id}]}],
      missing_images: Hash[missing_images.collect{|i| [i.image_id, {name: i.name, tenant_id: i.tenant_id}]}],
      missing_routers: Hash[missing_routers.collect{|i| [i.router_id, {name: i.name, tenant_id: i.tenant_id}]}],
      new_instances: Hash[new_instances.collect{|k,v| [k, {name: v['name'], tenant_id: v['tenant_id']}]}]
    }
    results.merge(:sane => results.values.none?(&:present?))
  end

  def self.notify!(data)
    msg = Mailer.usage_sanity_failures(data).text_part.to_s
    ignore = "Content-Type: text/plain;\r\n charset=UTF-8\r\nContent-Transfer-Encoding: 7bit\r\n\r\n"
    msg.gsub! ignore, ''
    Notifications.notify(:sanity_check, msg)
  end

  def self.live_instances
    Rails.cache.fetch('sanity_live_instances', expires_in: 10.minutes) do
      Hash[Fog::Compute.new(OPENSTACK_ARGS).list_servers_detail(:all_tenants => true).body['servers'].collect{|s| [s['id'], {'status' => s['status'].downcase, 'name' => s['name'], 'tenant_id' => s['tenant_id']}]}]
    end
  end

  def self.live_images
    Rails.cache.fetch('sanity_live_images', expires_in: 10.minutes) do
      Fog::Compute.new(OPENSTACK_ARGS).list_images.body['images'].collect{|s| s['id']}
    end
  end

  def self.live_routers
    Rails.cache.fetch('sanity_live_routers', expires_in: 10.minutes) do
      Fog::Network.new(OPENSTACK_ARGS).list_routers.body['routers'].collect{|s| s['id']}
    end
  end

  def self.check_instance_state(live, recorded)
    if live.include?('rescue')
      return recorded.include?('rescue')
    else
      live == recorded
    end
  end

  def self.instance_in_error_state(instance)
    Fog::Compute.new(OPENSTACK_ARGS).get_server_details(instance).body['server']['status'].downcase == 'error'
  rescue Fog::Compute::OpenStack::NotFound
    false
  end
end