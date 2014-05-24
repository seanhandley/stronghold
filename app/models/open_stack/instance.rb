module OpenStack
  class Instance < OpenStackObject::Server

    attributes :name, :state

    methods :reboot, :wait_for

  end
end