class Tenant < ActiveRecord::Base
  include OffboardingHelper

  belongs_to :organization

  validates :organization, :presence => true
  validates :name, length: {minimum: 1}, allow_blank: false

  syncs_with_keystone as: 'OpenStack::Tenant', actions: [:create, :destroy]
  syncs_with_ceph     as: 'Ceph::User',        actions: [:create, :destroy]

  has_many :user_tenant_roles
  has_many :users, :through => :user_tenant_roles

  def reference
    organization.staff? ? "datacentred" : "#{organization.reference}_#{name}"
  end

  def keystone_params
    { name: reference, enabled: false,
      description: "Customer: #{organization.name}, Project: #{name}" 
    }
  end

  def ceph_params
    { 'uid' => uuid, 'display-name' => name}
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

end
