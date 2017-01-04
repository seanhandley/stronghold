module Admin
  class FreeIpsController < AdminBaseController

    def index
      @floating_ips = OpenStackConnection.network.list_floating_ips.body['floatingips']
      @free_ips_count = @floating_ips.select do |i|
        i['status'] == 'DOWN'
      end.count
      @floating_ips_count = @floating_ips.count
    end

  end
end
