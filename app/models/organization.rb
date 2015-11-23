class Organization < ActiveRecord::Base
  include StripeHelper
  include Freezable
  include Migratable
  include UsageInformation

  audited only: [:name, :time_zone, :locale, :billing_address1, :billing_address2,
                 :billing_city, :billing_postcode, :billing_country, :phone]

  has_associated_audits

  syncs_with_salesforce

  after_save :generate_reference, :generate_reporting_code, :on => :create
  before_save :check_limited_storage, :if => Proc.new{|o| o.limited_storage_changed? }

  validates :name, length: {minimum: 1}, allow_blank: false
  validates :reference,      :uniqueness => true, :if => Proc.new{|o| o.reference.present? } 
  validates :reporting_code, :uniqueness => true, :if => Proc.new{|o| o.reporting_code.present? } 

  has_many :users, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :invoices, class_name: 'Billing::Invoice', dependent: :destroy
  has_many :tenants, dependent: :destroy
  has_and_belongs_to_many :products, -> { uniq }
  has_many :organization_vouchers, {dependent: :destroy}, -> { uniq }
  has_many :vouchers, :through => :organization_vouchers
  has_many :usages, class_name: 'Billing::Usage'

  belongs_to :primary_tenant, class_name: 'Tenant'
  belongs_to :customer_signup

  scope :paying,       -> { where('started_paying_at is not null') }
  scope :billable,     -> { all.select{|o| !o.test_account?} }
  scope :cloud,        -> { all.select(&:cloud?) }
  scope :active,       -> { all.select{|o| o.state == OrganizationStates::Active && !o.disabled?}}
  scope :self_service, -> { where('self_service = true') }
  scope :pending,      -> { all.select{|o| o.state == OrganizationStates::Fresh }}
  scope :frozen,       -> { where(in_review: true)}

  serialize :quota_limit

  def quota_limit
    read_attribute(:quota_limit) || {}
  end

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

  def new_projects_remaining
    projects_limit - tenants.count
  end

  def active_vouchers(from_date, to_date)
    return [] if from_date > to_date
    organization_vouchers.select do |v|
      (from_date < v.updated_at && to_date >= v.updated_at) ||
      (from_date < v.expires_at && to_date >= v.expires_at)
    end
  end

  def payment_card_type
    return nil unless customer_signup && customer_signup.stripe_customer && customer_signup.stripe_customer.respond_to?(:sources)
    card = customer_signup.stripe_customer.sources.data.first
    card ? "#{card.brand} #{card.funding}" : nil
  end

  # Mutative Methods

  def enable!
    unless Rails.env.test?
      tenants.each do |tenant|
        OpenStackConnection.identity.update_tenant(tenant.uuid, enabled: true)
      end
      users.each do |user|
        OpenStackConnection.identity.update_user(user.uuid, enabled: true)
      end
    end
    has_payment_methods!(true)
  end

  def disable!
    unless Rails.env.test?
      tenants.each do |tenant|
        OpenStackConnection.identity.update_tenant(tenant.uuid, enabled: false)
      end
      users.each do |user|
        OpenStackConnection.identity.update_user(user.uuid, enabled: false)
      end
    end
    update_attributes(disabled: true)
  end

  def manually_activate!
    return false unless state == OrganizationStates::Fresh 
    update_attributes(started_paying_at: Time.now.utc, self_service: false)
    enable!
    create_default_network!
    set_quotas!
  end

  def complete_signup!(args)
    update_attributes(stripe_customer_id: args[:stripe_customer_id])
    update_attributes(started_paying_at: Time.now.utc)
    ActivateCloudResourcesJob.perform_later(self, args[:voucher])
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

  def set_quotas!(voucher=nil)
    quota = (voucher && voucher.restricted?) ? 'restricted' : 'standard'
    update_attributes(quota_limit: StartingQuota[quota])
    tenants.each{|tenant| tenant.update_attributes(quota_set: StartingQuota[quota])}
    update_attributes(limited_storage: true) if voucher && voucher.restricted?
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
      t = tenants.create name: "#{reference}_primary"
      update_column(:primary_tenant_id, t.id)
    end
  end

  def generate_reporting_code
    return nil if reporting_code
    letters = (0...3).map { ('a'..'z').to_a[rand(26)] }.join.upcase
    numbers = rand(999).to_s.rjust(3, '0')
    code = "DC-#{letters}-#{numbers}"
    if Organization.all.collect(&:reporting_code).include?(code)
      generate_reporting_code
    else
      update_column(:reporting_code, code)
    end
  end

  def create_default_network!
    tenants.collect(&:uuid).each do |tenant_id|
      next if OpenStackConnection.network.list_routers(tenant_id: tenant_id).body['routers'].count > 0
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

  def check_limited_storage
    SetCephQuotaJob.perform_later(self)
  end
end

module OrganizationStates
  Active = 'active'
  HasNoPaymentMethods = 'no_payment_methods'
  Disabled = 'disabled'
  Fresh = 'fresh'
end
