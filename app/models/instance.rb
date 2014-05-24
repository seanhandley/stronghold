class Instance < OpenStackObject::Compute

  attributes :name, :state

  methods :reboot, :wait_for

end