class Organization < ActiveRecord::Base
  include StripeHelper

  audited only: [:name, :time_zone, :locale, :billing_address1, :billing_address2,
                 :billing_city, :billing_postcode, :billing_country, :phone]

  has_associated_audits

  syncs_with_salesforce

  after_save :generate_reference, :on => :create

  validates :name, length: {minimum: 1}, allow_blank: false
  validates :reference, :uniqueness => true

  has_many :users, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :tenants, dependent: :destroy
  has_and_belongs_to_many :products, -> { uniq }
  has_many :organization_vouchers, {dependent: :destroy}, -> { uniq }
  has_many :vouchers, :through => :organization_vouchers

  belongs_to :primary_tenant, class_name: 'Tenant'
  belongs_to :customer_signup

  scope :paying, -> { where('started_paying_at is not null') }
  scope :trial,  -> { where(started_paying_at: nil) }
  scope :cloud,  -> { all.select(&:cloud?) }
  scope :active, -> { all.select{|o| o.state == OrganizationStates::Active && !o.disabled?}}

  def staff?
    (reference == STAFF_REFERENCE)
  end

  def has_payment_method?
    return true unless self_service?
    return false unless known_to_payment_gateway?
    Rails.cache.fetch("org_#{id}_has_payment_method", expires_in: 1.hour) do
      rescue_stripe_errors(lambda {|msg| true}) do
        stripe_has_valid_source?(stripe_customer_id)
      end
    end
  end

  def known_to_payment_gateway?
    !!stripe_customer_id || !self_service?
  end

  def colo?
    products.collect(&:name).include? 'Colocation'
  end

  def storage?
    products.collect(&:name).include? 'Storage'
  end

  def compute?
    products.collect(&:name).include? 'Compute'
  end

  def cloud?
    compute? || storage?
  end

  def paying?
    !!started_paying_at
  end

  def admin_users
    users.select(&:admin?)
  end

  def enable!
    tenants.each do |tenant|
      Fog::Identity.new(OPENSTACK_ARGS).update_tenant(tenant.uuid, enabled: true)
    end
    users.each do |user|
      # Enable the user
      Fog::Identity.new(OPENSTACK_ARGS).update_user(user.uuid, enabled: true)
    end
    has_payment_methods!(true)
  end

  def disable!
    tenants.each do |tenant|
      Fog::Identity.new(OPENSTACK_ARGS).update_tenant(tenant.uuid, enabled: false)
    end
    users.each do |user|
      # Enable the user
      Fog::Identity.new(OPENSTACK_ARGS).update_user(user.uuid, enabled: false)
    end
    update_attributes(disabled: true)
  end

  def complete_signup!(stripe_customer_id)
    update_attributes(stripe_customer_id: stripe_customer_id)
    update_attributes(started_paying_at: Time.now.utc)
    ActivateCloudResourcesJob.perform_later(self)
  end

  def active_vouchers(from_date, to_date)
    return [] if from_date > to_date
    organization_vouchers.select do |v|
      (from_date < v.updated_at && to_date >= v.updated_at) ||
      (from_date < v.expires_at && to_date >= v.expires_at)
    end
  end

  def has_payment_methods!(bool)
    if bool
      update_attributes(state: OrganizationStates::Active)
    else
      update_attributes(state: OrganizationStates::HasNoPaymentMethods)
      if Authorization.current_user
        Rails.cache.delete("org_#{Authorization.current_user.organization.id}_has_payment_method")
      end
    end
  end

  private

  def generate_reference
    return nil if reference
    generate_reference_step(name.parameterize.gsub('-','').downcase.slice(0,18), 0)
  end

  def generate_reference_step(ref, count)
    new_ref = "#{ref}#{count == 0 ? '' : count }"
    if Organization.all.collect(&:reference).include?(new_ref)
      generate_reference_step(ref, (count+1))
    else
      update_column(:reference, new_ref)
      t = tenants.create name: "primary"
      update_column(:primary_tenant_id, t.id)
    end
  end

  def create_default_network!
    tenants.collect(&:uuid).each do |tenant_id|
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

  def set_quotas!
    tenants.collect(&:uuid).each do |tenant_id|
      OpenStack::Tenant.set_self_service_quotas(tenant_id)
    end
  end
end

module OrganizationStates
  Active = 'active'
  HasNoPaymentMethods = 'no_payment_methods'
  Disabled = 'disabled'
  Fresh = 'fresh'
end
