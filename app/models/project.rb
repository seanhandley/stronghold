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
  validate :check_quota_set_is_valid, :check_quota_set_within_limits, on: [:create, :update]

  after_commit :sync_quota_set, on: [:create, :update]
  after_commit -> { CreateProjectDefaultNetworkJob.perform_later(uuid) if organization.cloud? }, on: :create

  accepts_nested_attributes_for :user_project_roles, allow_destroy: true, reject_if: proc { |attributes| User.find_by_id(attributes["user_id"]).blank? }

  serialize :quota_set

  scope :for_usage_tracking, -> { with_deleted.joins(:organization).where("organizations.track_usage = ?", true) }

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
    errors.add(:base, "This account's limits only permit #{pluralize organization.projects_limit, 'project'}") unless organization.new_projects_remaining > 0
    throw :abort
  end

  def check_quota_set_is_valid
    quotas = quota_set.stringify_keys!
    unless quotas.is_a? Hash
      errors.add(:quota_set, "must be a hash")
      throw :abort
    end
    unless quotas.keys.all?{|k| StartingQuota['standard'].keys.include? k}
      errors.add(:quota_set, "top level keys are invalid. Valid keys are #{StartingQuota['standard'].keys}")
      throw :abort
    end
    StartingQuota['standard'].each do |top_level_key, sub_quotas|
      next unless quotas[top_level_key]
      unless quotas[top_level_key].is_a? Hash
        errors.add(:quota_set, "must be a hash")
        throw :abort
      end
      quotas[top_level_key].stringify_keys!
      unless quotas[top_level_key].keys.all?{|k| sub_quotas.keys.include? k}
        errors.add(:quota_set, "#{top_level_key} keys are invalid. Valid keys are #{StartingQuota['standard'][top_level_key].keys}.")
        throw :abort
      end
      (errors.add(:quota_set, "values must all be numeric") && break) unless quotas[top_level_key].values.all? {|v| Integer(v.to_s) rescue false }
      errors.add(:quota_set, "values must all be above zero") unless quotas[top_level_key].values.all? {|v| Integer(v.to_s) > 0 }
    end
    throw :abort if errors.any?
  end

  def check_quota_set_within_limits
    ['compute', 'volume', 'network'].each do |key|
      next unless quota_set[key]
      quota_set[key].each do |k,v|
        if organization.quota_limit[key][k].to_i < v.to_i
          errors.add(:quota_set, "requested quota for #{k.humanize} exceeds the maximum limit allowed for your account")
          throw :abort
        end
      end
    end
  end

  def sync_quota_set
    SyncQuotaSetJob.perform_later(self)
  end

end
