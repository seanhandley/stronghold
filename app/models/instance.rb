require 'fog'

class Instance

  def initialize(server)
    @server = server
    delegations.each{|a| class_eval{|c| delegate a.to_sym, to: :server}}
  end

  def to_s
    "#<Instance:#{id} #{delegations.collect{|d| "@#{d}=#{send(d.to_sym).inspect}"}.join ', '}>"
  end

  def id
    server.id
  end

  def inspect
    to_s
  end

  class << self

    def all
      compute.servers.map{|s| new(s) }
    end

    def find_all_by(attribute, value)
      [compute.servers.find {|s| s.send(attribute.to_sym) == value}].flatten.map do |s|
        new(s)
      end
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