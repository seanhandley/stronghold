class Project < ApplicationRecord
  include OffboardingHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper
  include QuotaUsage

  audited only: [:name, :uuid], :associated_with => :organization
  has_associated_audits

  acts_as_paranoid

  belongs_to :organization

  validates :organization, :presence => true
  validates :name, length: {minimum: 1}, allow_blank: false, :uniqueness => true

  syncs_with_keystone as: 'OpenStack::Project', actions: [:create, :destroy, :update]
  syncs_with_ceph     as: 'Ceph::User',        actions: [:create, :destroy]

  has_and_belongs_to_many :roles
  has_many :user_project_roles, dependent: :destroy
  has_many :users, -> { distinct }, :through => :user_project_roles

  has_many :billing_instances, primary_key: :uuid, class_name: 'Billing::Instance'
  has_many :billing_volumes, primary_key: :uuid, class_name: 'Billing::Volume'
  has_many :billing_images, primary_key: :uuid, class_name: 'Billing::Image'
  has_many :billing_external_gateways, primary_key: :uuid, class_name: 'Billing::ExternalGateway'
  has_many :billing_ips, primary_key: :uuid, class_name: 'Billing::Ip'
  has_many :billing_storage_objects, primary_key: :uuid, class_name: 'Billing::ObjectStorage'
  has_many :billing_ip_quotas, primary_key: :uuid, class_name: 'Billing::IpQuota'

  validate {|t| readonly! if t.persisted? && Project.find(id).staff_project? && name_changed? }
  before_destroy {|t| readonly! if t.persisted? && Project.find(id).staff_project? }
  before_destroy {|t| offboard(t, {})}
  validate :check_projects_limit, on: :create
  validate :check_quota_set, on: [:create, :update]

  after_commit :sync_quota_set, on: [:create, :update]
  after_commit -> { CreateProjectDefaultNetworkJob.perform_later(uuid) if organization.cloud? }, on: :create

  accepts_nested_attributes_for :user_project_roles, allow_destroy: true, reject_if: proc { |attributes| User.find_by_id(attributes["user_id"]).blank? }

  serialize :quota_set

  def quota_set
    read_attribute(:quota_set) || StartingQuota['standard']
  end

  def staff_project?
    self.name == 'datacentred'
  end

  def reference
    name
  end

  def keystone_params
    { name: reference.to_ascii,
      description: "Customer: #{organization.name}, Project: #{name}".to_ascii
    }
  end

  def ceph_params
    { 'uid' => uuid, 'display-name' => name}
  end

  def enable!
    OpenStackConnection.identity.update_project(uuid, enabled: true) unless Rails.env.test?
  end

  def disable!
    OpenStackConnection.identity.update_project(uuid, enabled: false) unless Rails.env.test?
  end

  def destroy_unless_primary
    destroy unless primary_project?
  end

  def primary_project?
    organization ? organization.primary_project_id == id : false
  end

  def quotas
    {
      "compute" => compute_quota,
      "volume"  => volume_quota,
      "network" => network_quota
    }
  end

  def compute_quota
    keys = StartingQuota['standard']['compute'].keys.map(&:to_s)
    OpenStackConnection.compute.get_quota(uuid).body['quota_set'].slice(*keys)
  end

  def volume_quota
    keys = StartingQuota['standard']['volume'].keys.map(&:to_s)
    OpenStackConnection.volume.get_quota(uuid).body['quota_set'].slice(*keys)
  end

  def network_quota
    keys = StartingQuota['standard']['network'].keys.map(&:to_s)
    OpenStackConnection.network.get_quota(uuid).body['quota'].slice(*keys)
  end

  private

  def check_projects_limit
    errors.add(:base, "This account's limits only permit #{pluralize organization.projects_limit, 'project'}. #{link_to 'Raise a ticket to request more?', Rails.application.routes.url_helpers.support_tickets_path}".html_safe) unless organization.new_projects_remaining > 0
    throw :abort
  end

  def check_quota_set
    return unless quota_set.keys.count >= 3
    ['compute', 'volume', 'network'].each do |key|
      quota_set[key].each do |k,v|
        if organization.quota_limit[key][k].to_i < v.to_i
          errors.add(:base, "Your requested quota for #{k.humanize} exceeds the maximum limit allowed for your account. #{link_to 'Raise a ticket to request more?', Rails.application.routes.url_helpers.support_tickets_path}".html_safe)
          throw :abort
        end
      end
    end
  end

  def sync_quota_set
    SyncQuotaSetJob.perform_later(self)
  end

end
