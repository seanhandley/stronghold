module OffboardingHelper
  def offboard(tenant, creds)
    return false unless tenant.respond_to?(:uuid) && tenant.uuid.is_a?(String)

    Rails.logger.info "Offboarding..."

    os_args = OPENSTACK_ARGS.dup
    os_args.merge!(creds)

    # Delete all instances to clear ports
    fog = Fog::Compute.new(os_args)
    instances = fog.list_servers_detail(all_tenants: true).body['servers'].select{|s| s['tenant_id'] == tenant.uuid}.map{|s| s['id']}
    instances.each do |instance|
      Rails.logger.info "Deleting instance #{instance}"
      fog.delete_server(instance)
    end

    images = fog.list_images_detail(owner: tenant.uuid).body['images'].select{|i| i['metadata']['owner_id'] == tenant.uuid}.map{|i| i['id']}
    images.each do |image|
      begin
        Rails.logger.info "Deleting image #{image}"
        fog.delete_image(image)
      rescue Excon::Errors::Error
      end
    end

    fog = Fog::Volume.new(os_args)
    snapshots = fog.list_snapshots(true, :all_tenants => true).body['snapshots'].select{|s| s["os-extended-snapshot-attributes:project_id"] == tenant.uuid}.map{|s| s['id']}
    snapshots.each do |snapshot|
      Rails.logger.info "Deleting snapshot #{snapshot}"
      fog.delete_snapshot(snapshot)
    end

    volumes = fog.list_volumes(true, :all_tenants => true).body['volumes'].select{|v| v["os-vol-tenant-attr:tenant_id"] == tenant.uuid}.map{|v| v['id']}
    volumes.each do |volume|
      Rails.logger.info "Deleting volume #{volume}"
      fog.delete_volume(volume)
    end

    fog = Fog::Network.new(os_args)
    routers  = fog.list_routers(tenant_id:  tenant.uuid).body['routers'].map{|r| r['id']}
    subnets  = fog.list_subnets(tenant_id:  tenant.uuid).body['subnets'].map{|s| s['id']}
    networks = fog.list_networks(tenant_id: tenant.uuid).body['networks'].map{|n| n['id']}

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

    ports    = fog.list_ports(tenant_id:    tenant.uuid).body['ports'].map{|p| p['id']}
    # Iterate through ports and delete all
    Rails.logger.info "Deleting ports: #{ports.inspect}"
    ports.each    {|p| fog.delete_port(p)}
    # Iterate through routers and delete all
    Rails.logger.info "Deleting routers: #{routers.inspect}"
    routers.each  {|r| fog.delete_router(r)}
    # Iterate through subnets and delete all
    Rails.logger.info "Deleting subnets: #{subnets.inspect}"
    subnets.each  {|s| fog.delete_subnet(s)}
    # Iterate through networks and delete all
    Rails.logger.info "Deleting networks: #{networks.inspect}"
    networks.each {|n| fog.delete_network(n)}

    true
  end
end
