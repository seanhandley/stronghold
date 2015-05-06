module OffboardingFixtures
  def compute_mock
    compute_mock = MiniTest::Mock.new

    servers_response = MiniTest::Mock.new
    servers = {'servers' => [{'tenant_id' => '12345', 'id' => '1'},
                              # Server ID 2 is never referenced in mocks
                              {'tenant_id' => '54321', 'id' => '2'}]}
    servers_response.expect(:body, servers)

    compute_mock.expect(:list_servers_detail, servers_response, [Hash])
    compute_mock.expect(:delete_server, true, ['1'])

    images_response = MiniTest::Mock.new
    images = {'images' => [{'id' => '1'}, {'id' => '2'}]}
    images_response.expect(:body, images)

    compute_mock.expect(:list_images_detail, images_response, [Hash])
    ['1', '2'].each do |n|
      compute_mock.expect(:delete_image, true, [n])
    end

    compute_mock
  end

  def volume_mock
    volume_mock = MiniTest::Mock.new

    volumes_response = MiniTest::Mock.new
    volumes = {'volumes' => [{'os-vol-tenant-attr:tenant_id' => '12345', 'id' => '1'},
                              # Volume ID 2 is never referenced in mocks
                              {"os-vol-tenant-attr:tenant_id" => '54321', 'id' => '2'}]}
    volumes_response.expect(:body, volumes)

    volume_mock.expect(:list_volumes, volumes_response, [true, Hash])
    volume_mock.expect(:delete_volume, true, ['1'])

    snapshots_response = MiniTest::Mock.new
    snapshots = {'snapshots' => [{'os-extended-snapshot-attributes:project_id' => '12345', 'id' => '1'},
                              # Snapshot ID 2 is never referenced in mocks
                              {"os-extended-snapshot-attributes:project_id" => '54321', 'id' => '2'}]}
    snapshots_response.expect(:body, snapshots)

    volume_mock.expect(:list_snapshots, snapshots_response, [true, Hash])
    volume_mock.expect(:delete_snapshot, true, ['1'])
    volume_mock
  end

  def network_mock
    network_mock = MiniTest::Mock.new

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
    end

    network_mock
  end
end
