class CustomerSignupGenerator
  include ActiveModel::Validations

  attr_reader :customer_signup

  def initialize(params={})
    if params[:customer_signup_id]
      @customer_signup = CustomerSignup.find(customer_signup_id)
    else
      @customer_signup = CustomerSignup.create(params)
    end
  end

  def verify_details!
    @customer_signup.valid?
  end

  def confirm_payment_details!
    @customer_signup.update_attributes(payment_verified: true)
  end

  def confirm_signup!
    if true
      # ensure they've ticked the policy stuff
    else
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
    false   
  end

  private

  def create_customer
    @organization = Organization.create! name: @organization_name
    @products.each do |product_id|
      @organization.products << Product.find(product_id)
    end
    @organization.save!
    @extra_tenants.split(',').map(&:strip).map(&:downcase).uniq.each do |tenant|
      @organization.tenants.create(name: tenant)
    end
    if colo_only?
      @organization.tenants.each do |tenant|
        OpenStack::Tenant.find(tenant.uuid).zero_quotas
      end
    end
    create_default_network(@organization) unless colo_only?
    @invite = Invite.create! email: @email, power_invite: true, organization: @organization
    Mailer.signup(@invite.id).deliver_later
  end

  def colo_only?
    products.collect{|p| Product.find(p).name}.include?('Colocation') && products.count == 1
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