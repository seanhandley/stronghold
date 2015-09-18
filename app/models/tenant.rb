class Tenant < ActiveRecord::Base
  include OffboardingHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::UrlHelper

  belongs_to :organization

  validates :organization, :presence => true
  validates :name, length: {minimum: 1}, allow_blank: false, :uniqueness => true

  syncs_with_keystone as: 'OpenStack::Tenant', actions: [:create, :destroy, :update]
  syncs_with_ceph     as: 'Ceph::User',        actions: [:create, :destroy]

  has_many :user_tenant_roles, dependent: :destroy
  has_many :users, :through => :user_tenant_roles

  validate {|t| readonly! if t.persisted? && Tenant.find(id).staff_tenant? && name_changed? }
  before_destroy {|t| readonly! if t.persisted? && Tenant.find(id).staff_tenant? }
  validate :check_projects_limit

  accepts_nested_attributes_for :user_tenant_roles, allow_destroy: true

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
    Fog::Identity.new(OPENSTACK_ARGS).update_tenant(uuid, enabled: true)
  end

  def disable!
    Fog::Identity.new(OPENSTACK_ARGS).update_tenant(uuid, enabled: false)
  end

  def destroy_unless_primary
    destroy unless primary_tenant?
  end

  def primary_tenant?
    organization ? organization.primary_tenant_id == id : false
  end

  def quotas
    Rails.cache.fetch("quotas_for_#{uuid}", expires_in: 1.hour) do
      {
        "compute" => compute_quota,
        "volume"  => volume_quota,
        "network" => network_quota,
        "object_storage" => storage_quota
      }
    end
  end

  private

  def compute_quota
    keys = ["instances", "cores", "ram"]
    Fog::Compute.new(OPENSTACK_ARGS).get_quota(uuid).body['quota_set'].slice(*keys)
  end

  def volume_quota
    keys = ["volumes", "snapshots", "gigabytes"]
    Fog::Volume.new(OPENSTACK_ARGS).get_quota(uuid).body['quota_set'].slice(*keys)
  end

  def network_quota
    keys = ["floatingip", "router"]
    Fog::Network.new(OPENSTACK_ARGS).get_quota(uuid).body['quota'].slice(*keys)
  end

  def storage_quota
    { "" => organization.limited_storage? ? '5 GB' : 'Unlimited'}
  end

  def check_projects_limit
    return true if persisted?
    errors.add(:base, "Your quota only permits #{pluralize organization.projects_limit, 'project'}. #{link_to 'Raise a ticket to request more?', Rails.application.routes.url_helpers.support_tickets_path}".html_safe) unless organization.new_projects_remaining > 0
  end

end
