class AdminConstraint
  def initialize
    @ipv4_cidrs = []
    @ipv4_cidrs.push NetAddr::CIDR.create('127.0.0.0/8')
    @ipv4_cidrs.push NetAddr::CIDR.create('TODO: Add our IPv4 Subnet')
    @ipv6_cidrs = []
    @ipv6_cidrs.push NetAddr::CIDR.create('TODO: Add our IPv6 Subnet')
  end

  def matches?(request)
    ip_version_contraints = IPAddress.parse(request.remote_ip).ipv6? ? @ipv6_cidrs : @ipv4_cidrs
    has_valid_ips = ip_version_contraints.select { |cidr| cidr.contains? request.remote_ip }
    has_valid_ips.any?
  end
end