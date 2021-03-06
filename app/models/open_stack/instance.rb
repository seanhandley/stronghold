module OpenStack
  class Instance < OpenStackObject::Server
    attributes :name, :state, :all_addresses, :tenant_id, :user_id

    methods :reboot, :wait_for

    def initialize(params)
      super(params)
      wait_for { ready? } if state == nil
    end

    def start
      service_method do |s|
        if state.downcase == 'paused'
          s.unpause_server(id)
        else
          s.resume_server(id)
        end
        wait_for { ready? }
        reload
      end
      audit('start')
      self
    end

    def stop
      service_method do |s|
        s.suspend_server(id)
        wait_for { state.downcase == 'suspended' }
        reload
      end
      audit('stop')
      self
    end

    def pause
      service_method do |s|
        s.pause_server(id)
        wait_for { state.downcase == 'paused' }
        reload
      end
      audit('pause')
      self
    end

    def destroy
      # Ensure we disassociate floating IPs before removal
      all_addresses.each do |address|
        service_method do |s|
          s.disassociate_address(id, address['ip'])
          s.release_address(address['id'])
        end
      end
      audit('destroy')
      super
    end

  end
end