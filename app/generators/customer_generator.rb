class CustomerGenerator
  include ActiveModel::Validations

  attr_reader :organization_name, :email, :products, :extra_tenants

  def initialize(params={})
    @organization_name = params[:organization_name]
    @email             = params[:email]
    @products          = params[:products]
    @extra_tenants     = params[:extra_tenants]
  end

  def generate!
    if @organization_name.blank?
      errors.add :base, "Must provide an organization name"
    elsif @email.blank? || !(@email =~ /.+@.+\..+/)
      errors.add :base, "Must provide a valid email address"
    elsif User.find_by_email(@email).present?
      errors.add :base, "Email already exists in the system"
    else
      @organization = Organization.create! name: @organization_name
      @products.each do |_, product_id|
        @organization.products << Product.find(product_id)
      end
      @organization.save!
      @extra_tenants.split(',').map(&:strip).map(&:downcase).uniq.each do |tenant|
        uuid = @organization.tenants.create(name: tenant).uuid
        OpenStack::Tenant.find(uuid).zero_quotas if colo_only?
      end
      create_default_network(@organization) unless colo_only?
      @invite = Invite.create! email: @email, power_invite: true, organization: @organization
      Mailer.signup(@invite.id).deliver
      return true
    end 
    false
  end

  private

  def colo_only?
    products.keys.include?'Colocation' && products.count == 1
  end

  def create_default_network(organization)
    organization.tenants.collect(&:uuid).each do |tenant_id|
      n = Fog::Network.new(OPENSTACK_ARGS).networks.create name: 'default', tenant_id: tenant_id
      s = Fog::Network.new(OPENSTACK_ARGS).subnets.create name: 'default', cidr: '192.168.0.0/24',
                                   network_id: n.id, ip_version: 4, dns_nameservers: ['8.8.8.8', '8.8.4.4'],
                                   tenant_id: tenant_id
      external_network = Fog::Network.new(OPENSTACK_ARGS).networks.select{|n| n.router_external == true }.first
      r = Fog::Network.new(OPENSTACK_ARGS).routers.create name: 'default', tenant_id: tenant_id,
                                   external_gateway_info: external_network.id
      Fog::Network.new(OPENSTACK_ARGS).add_router_interface(r.id, s.id)

    end
  end
end