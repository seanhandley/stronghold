require 'fog'

class Instance

  def initialize(server)
    @server = server
    delegations.each{|a| class_eval{|c| delegate a.to_sym, to: :server}}
  end

  class << self

    def all
      compute.servers.map{|s| new(s) }
    end
    
    private

    def compute
      @@c ||= Fog::Compute.new(OPENSTACK_ARGS)
    end

  end

  private

  # Items to delegate down into the server object
  # Add as needed
  def delegations
    %w{name state}
  end

  def server
    @server
  end

end