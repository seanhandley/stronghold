class Admin::FreeIpsController < AdminBaseController

  def index
    @floating_ips = Fog::Network.new(OPENSTACK_ARGS).list_floating_ips.body['floatingips']
    @free_ips_count = @floating_ips.select do |i|
      i['status'] == 'DOWN'
    end.count
    @floating_ips_count = @floating_ips.count
  end

end
