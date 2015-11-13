class CustomerGenerator
  include ActiveModel::Validations

  attr_reader :organization_name, :email, :products, :extra_tenants, :salesforce_id

  def initialize(params={})
    @organization_name = params[:organization_name]
    @email             = params[:email]
    @extra_tenants     = params[:extra_tenants]
    @salesforce_id     = params[:salesforce_id]
    if params[:organization] && params[:organization][:product_ids]
      @products = params[:organization][:product_ids].select(&:present?)
    else
      @products = []
    end
  end

  def generate!
    if @organization_name.blank?
      errors.add :base, "Must provide an organization name"
    elsif @email.blank? || !(@email =~ /.+@.+\..+/)
      errors.add :base, "Must provide a valid email address"
    elsif User.find_by_email(@email).present?
      errors.add :base, "Email already exists in the system"
    elsif @products.none?
      errors.add :base, "Select at least one product"
    elsif @products.any? {|p| !Product.all.map(&:id).include?(p.to_i)}
      errors.add :base, "Products invalid"
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
    @organization = Organization.create! name: @organization_name, self_service: false, salesforce_id: @salesforce_id, projects_limit: @extra_tenants.split(',').count + 1
    @products.each do |product_id|
      @organization.products << Product.find(product_id)
    end
    @organization.save!
    @organization.enable!
    @extra_tenants.split(',').map(&:strip).map(&:downcase).uniq.each do |tenant|
      @organization.tenants.create(name: tenant)
    end
    if colo_only?
      @organization.tenants.each do |tenant|
        OpenStack::Tenant.find(tenant.uuid).zero_quotas
      end
    end
    create_default_network(@organization) unless colo_only?
    Invite.create! email: @email, power_invite: true, organization: @organization, tenant_ids: [@organization.primary_tenant.id]
    Notifications.notify(:internal_signup, "New customer account created: #{@email} invited to organization #{@organization_name}")
  end

  def colo_only?
    products.collect{|p| Product.find(p).name}.include?('Colocation') && products.count == 1
  end

  def create_default_network(organization)
    organization.tenants.collect(&:uuid).each do |tenant_id|
      n = OpenStackConnection.network.networks.create name: 'default', tenant_id: tenant_id
      s = OpenStackConnection.network.subnets.create name: 'default', cidr: '192.168.0.0/24',
                                   network_id: n.id, ip_version: 4, dns_nameservers: ['8.8.8.8', '8.8.4.4'],
                                   tenant_id: tenant_id
      external_network = OpenStackConnection.network.networks.select{|n| n.router_external == true }.first
      r = OpenStackConnection.network.routers.create name: 'default', tenant_id: tenant_id,
                                   external_gateway_info: external_network.id
      OpenStackConnection.network.add_router_interface(r.id, s.id)

    end
  end
end