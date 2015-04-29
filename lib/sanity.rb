module Sanity
  def self.check
    missing_instances = Billing::Instance.active.reject do |instance|
      if live_instances[instance.instance_id].nil?
        false
      else
        live_instances[instance.instance_id]['status'] == instance.current_state
      end
    end

    new_instances = live_instances.reject do |instance,_|
      Billing::Instance.find_by_instance_id(instance)
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
      missing_instances: Hash[missing_instances.collect{|i| [i.instance_id, i.name]}],
      missing_volumes: Hash[missing_volumes.collect{|i| [i.volume_id, i.name]}],
      missing_images: Hash[missing_images.collect{|i| [i.image_id, i.name]}],
      missing_routers: Hash[missing_routers.collect{|i| [i.router_id, i.name]}],
      new_instances: Hash[new_instances.collect{|k,v| [k, v['name']]}]
    }
    results.merge(:sane => results.values.none?(&:present?))
  end

  def self.notify!(data)
    msg = Mailer.usage_sanity_failures(data).html_part.body.raw_source.gsub("\n","<br />")
    Hipchat.notify('Sanity Check', 'Web', msg, :color => 'red')
  end

  def self.live_instances
    Rails.cache.fetch('sanity_live_instances', expires_in: 10.minutes) do
      Hash[Fog::Compute.new(OPENSTACK_ARGS).list_servers_detail(:all_tenants => true).body['servers'].collect{|s| [s['id'], {'status' => s['status'].downcase, 'name' => s['name']}]}]
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
end