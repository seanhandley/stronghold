class ProjectResources
  using FogRefinements
  attr_reader :project_uuid

  def initialize(project_uuid)
    @project_uuid = project_uuid
  end

  def create_default_network
    n = fog_network.networks.create name: default_name,  tenant_id: project_uuid
    s = fog_network.subnets.create  name: default_name,  cidr: default_cidr,
                                    network_id: n.id,    ip_version: 4,
                                    dns_nameservers:     default_dns,
                                    tenant_id:           project_uuid

    

    r = fog_network.routers.create name: default_name,    tenant_id: project_uuid,
                                   external_gateway_info: external_network.id

    fog_network.add_router_interface(r.id, s.id)
  end

  def destroy_default_network
    clear_router_gateways
    routers.each  {|r| fog_network.delete_router(r)}
    subnets.each  {|s| fog_network.delete_subnet(s)}
    networks.each {|n| fog_network.delete_network(n)}
  end

  def clear_router_gateways
    floating_ips.each {|p| fog_network.disassociate_floating_ip(p)}
    routers.each do |router|
      subnets.each do |subnet|
        begin
          fog_network.update_router router,  external_gateway_info: {}
          fog_network.remove_router_interface(router, subnet)
        rescue Fog::Network::OpenStack::NotFound
          # Ignore
        end
      end
    end  
  end

  def reattach_router_gateways
    routers.each do |router|
      subnets.each do |subnet|
        begin
          fog_network.update_router router,  external_gateway_info: {network_id: external_network.id}
          fog_network.add_router_interface(router, subnet)
        rescue Fog::Network::OpenStack::NotFound
          # Ignore
        end
      end
    end 
  end

  private

  def default_cidr
    '192.168.0.0/24'
  end

  def default_dns
    ['8.8.8.8', '8.8.4.4']
  end

  def external_network
    fog_network.networks.select{|n| n.router_external == true }.first
  end

  def filters
    { tenant_id: project_uuid, name: 'default' }
  end

  def routers
    fog_network.list_routers(filters).body['routers'].map{|r|   r['id']}
  end

  def subnets
    fog_network.list_subnets(filters).body['subnets'].map{|s|   s['id']}
  end

  def ports
    fog_network.list_ports.body['ports']
  end

  def networks
    fog_network.list_networks(filters).body['networks'].map{|n| n['id']}
  end

  def floating_ips
    fog_network.list_floating_ips.body['floatingips'].map{|n| n['id']}
  end

  def fog_network
    OpenStackConnection.network
  end

  def default_name
    'default'
  end
end
