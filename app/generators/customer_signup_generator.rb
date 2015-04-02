class CustomerSignupGenerator

  attr_reader :customer_signup

  def initialize(customer_signup_id)
    @customer_signup = CustomerSignup.find(customer_signup_id)
  end

  def generate!
    error = nil
    ActiveRecord::Base.transaction do
      begin
        create_customer
      rescue StandardError => e
        error = e
        raise ActiveRecord::Rollback
      end
    end

    raise error if error
    return true
  end

  private

  def create_customer
    @organization = Organization.create! name: @customer_signup.organization_name
    @organization.products << Product.find_by_name('Compute')
    @organization.products << Product.find_by_name('Storage')
    @organization.save!

    create_default_network_and_quotas(@organization)
    @invite = Invite.create! email: @customer_signup.email, power_invite: true,
                             organization: @organization, customer_signup: @customer_signup
    Mailer.signup(@invite.id).deliver_later
    Hipchat.notify('Self Service', 'Signups', "New user signed up: #{@customer_signup.email} becoming organization #{@organization.id}")
  end

  def create_default_network_and_quotas(organization)
    organization.tenants.collect(&:uuid).each do |tenant_id|
      n = Fog::Network.new(OPENSTACK_ARGS).networks.create name: 'default', tenant_id: tenant_id
      s = Fog::Network.new(OPENSTACK_ARGS).subnets.create name: 'default', cidr: '192.168.0.0/24',
                                   network_id: n.id, ip_version: 4, dns_nameservers: ['8.8.8.8', '8.8.4.4'],
                                   tenant_id: tenant_id
      external_network = Fog::Network.new(OPENSTACK_ARGS).networks.select{|n| n.router_external == true }.first
      r = Fog::Network.new(OPENSTACK_ARGS).routers.create name: 'default', tenant_id: tenant_id,
                                   external_gateway_info: external_network.id
      Fog::Network.new(OPENSTACK_ARGS).add_router_interface(r.id, s.id)
      OpenStack::Tenant.find(tenant_id).set_self_service_quotas
    end
  end
end