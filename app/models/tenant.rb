class Tenant < ActiveRecord::Base
  include OffboardingHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  acts_as_paranoid

  belongs_to :organization

  validates :organization, :presence => true
  validates :name, length: {minimum: 1}, allow_blank: false, :uniqueness => true

  syncs_with_keystone as: 'OpenStack::Tenant', actions: [:create, :destroy, :update]
  syncs_with_ceph     as: 'Ceph::User',        actions: [:create, :destroy]

  has_many :user_tenant_roles, dependent: :destroy
  has_many :users, :through => :user_tenant_roles

  has_many :billing_instances, primary_key: :uuid, class_name: 'Billing::Instance'
  has_many :billing_volumes, primary_key: :uuid, class_name: 'Billing::Volume'
  has_many :billing_images, primary_key: :uuid, class_name: 'Billing::Image'
  has_many :billing_external_gateways, primary_key: :uuid, class_name: 'Billing::ExternalGateway'
  has_many :billing_ips, primary_key: :uuid, class_name: 'Billing::Ip'
  has_many :billing_storage_objects, primary_key: :uuid, class_name: 'Billing::ObjectStorage'
  has_many :billing_ip_quotas, primary_key: :uuid, class_name: 'Billing::IpQuota'

  validate {|t| readonly! if t.persisted? && Tenant.find(id).staff_tenant? && name_changed? }
  before_destroy {|t| readonly! if t.persisted? && Tenant.find(id).staff_tenant? }
  before_destroy {|t| offboard(t, {})}
  validate :check_projects_limit, on: :create
  validate :check_quota_set

  after_commit :sync_quota_set, on: [:create, :update]

  accepts_nested_attributes_for :user_tenant_roles, allow_destroy: true

  serialize :quota_set

  def quota_set
    read_attribute(:quota_set) || {}
  end

  def staff_tenant?
    self.name == 'datacentred'
  end

  def reference
    name
  end

  def keystone_params
    { name: reference,
      description: "Customer: #{organization.name}, Project: #{name}" 
    }
  end

  def ceph_params
    { 'uid' => uuid, 'display-name' => name}
  end

  def enable!
    OpenStackConnection.identity.update_tenant(uuid, enabled: true)
  end

  def disable!
    OpenStackConnection.identity.update_tenant(uuid, enabled: false)
  end

  def destroy_unless_primary
    destroy unless primary_tenant?
  end

  def primary_tenant?
    organization ? organization.primary_tenant_id == id : false
  end

  private

  def check_projects_limit
    errors.add(:base, "Your account limits only permit #{pluralize organization.projects_limit, 'project'}. #{link_to 'Raise a ticket to request more?', Rails.application.routes.url_helpers.support_tickets_path}".html_safe) unless organization.new_projects_remaining > 0
  end

  def check_quota_set
    return unless quota_set.keys.count >= 3
    ['compute', 'volume', 'network'].each do |key|
      quota_set[key].each do |k,v|
        if organization.quota_limit[key][k].to_i < v.to_i
          return errors.add(:base, "Your requested quota for #{k.humanize} exceeds the maximum limit allowed for your account. #{link_to 'Raise a ticket to request more?', Rails.application.routes.url_helpers.support_tickets_path}".html_safe)
        end
      end
    end
  end

  def sync_quota_set
    SyncQuotaSetJob.perform_later(self)
  end

end
