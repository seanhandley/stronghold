module OffboardingFixtures
  def compute_mock
    compute_mock = MiniTest::Mock.new

    servers_response = MiniTest::Mock.new
    servers = {'servers' => [{'tenant_id' => '12345', 'id' => '1'},
                              # Server ID 2 is never referenced in mocks
                              {'tenant_id' => '54321', 'id' => '2'}]}
    servers_response.expect(:body, servers)

    server_volumes_response = MiniTest::Mock.new
    server_volumes = {'volumeAttachments' => [{'id' => '1'}]}

    compute_mock.expect(:list_servers_detail, servers_response, [Hash])
    server_volumes_response.expect(:body, server_volumes)
    compute_mock.expect(:get_server_volumes, server_volumes_response, ['1'])
    compute_mock.expect(:detach_volume, true, ['1', '1'])
    compute_mock.expect(:delete_server, true, ['1'])

    compute_mock
  end

  def volume_mock
    volume_mock = MiniTest::Mock.new

    volumes_response = MiniTest::Mock.new
    volumes = {'volumes' => [{'os-vol-tenant-attr:tenant_id' => '12345', 'id' => '1'},
                              # Volume ID 2 is never referenced in mocks
                              {"os-vol-tenant-attr:tenant_id" => '54321', 'id' => '2'}]}
    volumes_response.expect(:body, volumes)

    volume_mock.expect(:list_volumes_detailed, volumes_response, [Hash])
    volume_mock.expect(:delete_volume, true, ['1'])

    snapshots_response = MiniTest::Mock.new
    snapshots = {'snapshots' => [{'os-extended-snapshot-attributes:project_id' => '12345', 'id' => '1'},
                              # Snapshot ID 2 is never referenced in mocks
                              {"os-extended-snapshot-attributes:project_id" => '54321', 'id' => '2'}]}
    snapshots_response.expect(:body, snapshots)

    volume_mock.expect(:list_snapshots_detailed, snapshots_response, [Hash])
    volume_mock.expect(:delete_snapshot, true, ['1'])
    volume_mock
  end

  def network_mock
    network_mock = MiniTest::Mock.new

    floating_ips_response = MiniTest::Mock.new
    floating_ips = {'floatingips' => [{'id' => '1'}, {'id' => '2'}]}
    floating_ips_response.expect(:body, floating_ips)

    network_mock.expect(:list_floating_ips, floating_ips_response, [{tenant_id: "12345"}])

    routers_response = MiniTest::Mock.new
    routers = {'routers' => [{'id' => '1'}, {'id' => '2'}]}
    routers_response.expect(:body, routers)

    network_mock.expect(:list_routers, routers_response, [{tenant_id: "12345"}])

    subnets_response = MiniTest::Mock.new
    subnets = {'subnets' => [{'id' => '1'}, {'id' => '2'}]}
    subnets_response.expect(:body, subnets)

    network_mock.expect(:list_subnets, subnets_response, [{tenant_id: "12345"}])

    ports_response = MiniTest::Mock.new
    ports = { 'ports' => [{'id' => '1'}, {'id' => '2'}]}
    ports_response.expect(:body, ports)

    network_mock.expect(:list_ports, ports_response, [{tenant_id: "12345"}])

    networks_response = MiniTest::Mock.new
    networks = { 'networks' => [{'id' => '1'}, {'id' => '2'}]}
    networks_response.expect(:body, networks)

    network_mock.expect(:list_networks, networks_response, [{tenant_id: "12345"}])

    ['1', '2'].each do |n|
      ['1', '2'].each do |m|
        network_mock.expect(:remove_router_interface, true, [n, m])
      end
    end
    ['1', '2'].each do |n|
      network_mock.expect(:delete_port, true, [n])
      network_mock.expect(:delete_subnet, true, [n])
      network_mock.expect(:delete_router, true, [n])
      network_mock.expect(:delete_network, true, [n])
      network_mock.expect(:disassociate_floating_ip, true, [n])
    end

    network_mock
  end
end
