module OffboardingHelper
  def offboard(project, creds)
    return false unless project.respond_to?(:uuid) && project.uuid.is_a?(String)

    Rails.logger.info "Offboarding..."

    os_args = OPENSTACK_ARGS.dup
    os_args.merge!(creds)

    # Delete all instances to clear ports
    fog = OpenStackConnection.compute
    instances = fog.list_servers_detail(all_tenants: true).body['servers'].select{|s| s['tenant_id'] == project.uuid}.map{|s| s['id']}
    instances.each do |instance|
      Rails.logger.info "Deleting instance #{instance}"
      with_auto_retry(3) { fog.delete_server(instance)}
    end

    # There's no way currently with Glance to know which image belongs to who
    # images = fog.list_images_detail(owner: project.uuid).body['images'].map{|i| i['id']}
    # images.each do |image|
    #   begin
    #     Rails.logger.info "Deleting image #{image}"
    #     fog.delete_image(image)
    #   rescue Excon::Errors::Error
    #   end
    # end

    fog = OpenStackConnection.volume
    snapshots = fog.list_snapshots_detailed(:all_tenants => true).body['snapshots'].select{|s| s["os-extended-snapshot-attributes:project_id"] == project.uuid}.map{|s| s['id']}
    snapshots.each do |snapshot|
      Rails.logger.info "Deleting snapshot #{snapshot}"
      with_auto_retry(3) { fog.delete_snapshot(snapshot) }
    end

    volumes = fog.list_volumes_detailed(:all_tenants => true).body['volumes'].select{|v| v["os-vol-tenant-attr:tenant_id"] == project.uuid}.map{|v| v['id']}
    volumes.each do |volume|
      Rails.logger.info "Deleting volume #{volume}"
      with_auto_retry(3) { fog.delete_volume(volume) }
    end

    fog = OpenStackConnection.network
    floating_ips = fog.list_floating_ips(tenant_id:  project.uuid).body['floatingips'].map{|r| r['id']}
    routers      = fog.list_routers(tenant_id:  project.uuid).body['routers'].map{|r| r['id']}
    subnets      = fog.list_subnets(tenant_id:  project.uuid).body['subnets'].map{|s| s['id']}
    networks     = fog.list_networks(tenant_id: project.uuid).body['networks'].map{|n| n['id']}

    # Iterate through floating IPs and delete all
    Rails.logger.info "Disassociating floating IPs: #{floating_ips.inspect}"
    floating_ips.each do |p|
      with_auto_retry(3) { fog.disassociate_floating_ip(p) }
    end

    # Iterate through routers and remove router interface
    routers.each do |router|
      subnets.each do |subnet|
        begin
          fog.remove_router_interface(router, subnet)
        rescue Fog::Network::OpenStack::NotFound
          # Ignore
        end
      end
    end

    ports    = fog.list_ports(tenant_id:    project.uuid).body['ports'].map{|p| p['id']}
    # Iterate through ports and delete all
    Rails.logger.info "Deleting ports: #{ports.inspect}"
    ports.each    {|p| with_auto_retry(3) { fog.delete_port(p) }}
    # Iterate through routers and delete all
    Rails.logger.info "Deleting routers: #{routers.inspect}"
    routers.each  {|r| with_auto_retry(3) { fog.delete_router(r) }}
    # Iterate through subnets and delete all
    Rails.logger.info "Deleting subnets: #{subnets.inspect}"
    subnets.each  {|s| with_auto_retry(3) { fog.delete_subnet(s) }}
    # Iterate through networks and delete all
    Rails.logger.info "Deleting networks: #{networks.inspect}"
    networks.each {|n| with_auto_retry(3) { fog.delete_network(n) }}

    true
  end

  def with_auto_retry(retries, wait=2, &blk)
    last_error = nil
    retries.times do
      begin
        yield
        return true
      rescue Fog::Errors::Error => e
        last_error = e
        sleep wait
      end
    end
    Honeybadger.notify(last_error) if last_error
  end
end
