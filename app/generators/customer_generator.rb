class CustomerGenerator
  include ActiveModel::Validations

  attr_reader :organization_name, :email, :colo_only, :extra_tenants

  def initialize(params={})
    @organization_name = params[:organization_name]
    @email             = params[:email]
    @colo_only         = params[:colo_only]
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
      @extra_tenants.split(',').map(&:strip).map(&:downcase).uniq.each do |tenant|
        uuid = @organization.tenants.create(name: tenant).uuid
        OpenStack::Tenant.find(uuid).zero_quotas if @colo_only
      end
      create_default_network(@organization)
      @invite = Invite.create! email: @email, power_invite: true, organization: @organization
      Mailer.signup(@invite.id).deliver
      return true
    end 
    false
  end

  private

  def create_default_network(organization)
    organization.tenants.collect(&:uuid).each |tenant_id|
      n = OpenStack::Network.create name: 'default', tenant_id: tenant_id
      s = OpenStack::Subnet.create name: 'default', cidr: '192.168.0.0/24',
                                   network_id: n.id, ip_version: 4
      external_network = OpenStack::Network.all.select{|n| n.router_external == true }.first
      r = OpenStack::Router.create name: 'default', tenant_id: tenant_id,
                                   external_gateway_info: external_network.id
      OpenStack::Port.create name: 'default', network_id: n.id, device_id: r.id, 
                             tenant_id: tenant_id
    end
  end
end