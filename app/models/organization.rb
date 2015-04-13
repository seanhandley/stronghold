class Organization < ActiveRecord::Base
  audited
  has_associated_audits

  syncs_with_salesforce

  after_save :generate_reference, :on => :create

  validates :name, length: {minimum: 1}, allow_blank: false
  validates :reference, :uniqueness => true

  has_many :users, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :tenants, dependent: :destroy
  has_and_belongs_to_many :products

  belongs_to :primary_tenant, class_name: 'Tenant'

  scope :paying, -> { where('started_paying_at is not null') }
  scope :trial,  -> { where(started_paying_at: nil) }
  scope :cloud,  -> { all.select(&:cloud?) }

  def staff?
    (reference == STAFF_REFERENCE)
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
    users.each do |user|
      # Enable the user
      Fog::Identity.new(OPENSTACK_ARGS).update_user(user.uuid, enabled: true)
    end
  end

  def complete_signup!(stripe_customer_id)
    update_attributes(stripe_customer_id: stripe_customer_id)
    enable!
    create_default_network!
    set_quotas!
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
      OpenStack::Tenant.find(tenant_id).set_self_service_quotas
    end
  end
end