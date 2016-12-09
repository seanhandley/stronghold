class Organization < ActiveRecord::Base
  include StripeHelper
  include Freezable
  include Migratable
  include UsageInformation
  include OrganizationTransitionable

  audited only: [:name, :time_zone, :locale, :billing_address1, :billing_address2,
                 :billing_city, :billing_postcode, :billing_country, :phone, :billing_contact]

  has_associated_audits

  syncs_with_salesforce as: 'Account', actions: [:create, :update]

  def salesforce_args
    {
      Name: name, Type: 'Customer',
      Billingstreet: [billing_address1, billing_address2].join("\n").strip,
      Billingcity: billing_city, Billingpostalcode: billing_postcode,
      Billingcountry: Country.find_country_by_alpha2(billing_country).try(:name), Phone: phone,
      c2g__CODAReportingCode__c: reporting_code,
      c2g__CODAAccountTradingCurrency__c: 'GBP',
      c2g__CODABillingMethod__c: self_service? ? 'Self-Service' : nil,
      c2g__CODADescription1__c: payment_card_type,
      c2g__CODABaseDate1__c: "Invoice Date",
      c2g__CODADaysOffset1__c: 0,
      # c2g__CODAInvoiceEmail__c: billing_contact,
      Monthly_VCPU_Hours__c: monthly_vcpu_hours,
      Monthly_RAM_TBh__c: monthly_ram_tbh,
      Monthly_OpenStack_Storage_TBh__c: monthly_openstack_storage_tbh,
      Monthly_Ceph_Storage_TBh__c: monthly_ceph_storage_tbh,
      Usage_Value__c: monthly_usage_value,
      Weekly_Ceph_Storage_TBh__c: weekly_ceph_storage_tbh,
      Weekly_OpenStack_Storage_TBh__c: weekly_openstack_storage_tbh,
      Weekly_RAM_TBh__c: weekly_ram_tbh,
      Weekly_Usage_Value__c: weekly_spend,
      Weekly_VCPU_Hours__c: weekly_vcpu_hours,
      Discount_End_Date__c: discount_end_date,
      User_Accounts__c: users.count
    }
  end

  after_save :generate_reference, :generate_reporting_code, :on => :create
  before_save :check_limited_storage, :if => Proc.new{|o| o.limited_storage_changed? }

  validates :name, length: {minimum: 1}, allow_blank: false
  validates :reference,      :uniqueness => true, :if => Proc.new{|o| o.reference.present? }
  validates :reporting_code, :uniqueness => true, :if => Proc.new{|o| o.reporting_code.present? }

  has_many :users, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :invoices, class_name: 'Billing::Invoice', dependent: :destroy
  has_many :projects, dependent: :destroy
  has_and_belongs_to_many :products, -> { uniq }
  has_many :organization_vouchers, {dependent: :destroy}, -> { uniq }
  has_many :vouchers, :through => :organization_vouchers
  has_many :usages

  belongs_to :primary_project, class_name: 'Project'
  belongs_to :customer_signup

  scope :paying,                -> { where('started_paying_at is not null') }
  scope :billable,              -> { where(test_account: false, bill_automatically: true) }
  scope :cloud,                 -> { all.select(&:cloud?) }
  scope :active,                -> { where(state: 'active')}
  scope :self_service,          -> { where('self_service = true') }
  scope :pending,               -> { where(state: 'fresh')}
  scope :frozen,                -> { where(state: 'frozen')}
  scope :pending_without_users, -> { all.select{|o| o.fresh? && o.users.count == 0}}

  serialize :quota_limit

  def update_including_state(params={})
    transition_to!(params[:state]) if params[:state]
    update(params)
  end

  def frozen?
    state == 'frozen'
  end

  def fresh?
    state == 'fresh'
  end

  def closed?
    current_state == 'closed'
  end

  def quota_limit
    read_attribute(:quota_limit) || StartingQuota['standard']
  end

  def staff?
    (reference == STAFF_REFERENCE)
  end

  def show_costs?
    !test_account? || staff?
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

  def account_type
   self_service? ? 'Self Service' : 'Invoiced/Trial'
  end

  def known_to_payment_gateway?
    !!stripe_customer_id || !self_service?
  end

  def colo?
    products.collect(&:name).include? 'Colocation'
  end

  def colo_only?
    products.collect(&:name).include?('Colocation') && products.count == 1
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
    projects_limit - projects.count
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

  def set_quotas!(voucher=nil)
    quota = (voucher && voucher['restricted']) ? 'restricted' : 'standard'
    update_attributes(quota_limit: StartingQuota[quota])
    projects.each{|project| project.update_attributes(quota_set: StartingQuota[quota])}
    update_attributes(limited_storage: true) if voucher && voucher['restricted']
    true
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
      begin
        t = projects.create! name: "#{reference}_primary"
      rescue ActiveRecord::RecordNotSaved
        t = projects.create! name: "#{SecureRandom.hex.slice(0,16)}_primary"
      end
      update_column(:primary_project_id, t.id)
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

  def check_limited_storage
    SetCephQuotaJob.perform_later(self)
  end
end
