require 'fog/openstack'

module FogRefinements
  refine Fog::Network::OpenStack::Real do
    # This will be patched in a newer version of the gem
    def update_router(router_id, options = {})
      data = { 'router' => {} }

      [:name, :admin_state_up, :external_gateway_info].each do |key|
        data['router'][key] = options[key] if options[key]
      end

      request(
        :body     => Fog::JSON.encode(data),
        :expects  => 200,
        :method   => 'PUT',
        :path     => "routers/#{router_id}.json"
      )
    end
  end
end
