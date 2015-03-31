class Tenant < ActiveRecord::Base
  include OffboardingHelper

  belongs_to :organization

  validates :organization, :presence => true
  validates :name, length: {minimum: 1}, allow_blank: false
  before_destroy -> { offboard(self) }

  syncs_with_keystone as: 'OpenStack::Tenant', actions: [:create, :destroy]
  syncs_with_ceph     as: 'Ceph::User',        actions: [:create, :destroy]

  has_many :user_tenant_roles
  has_many :users, :through => :user_tenant_roles

  def reference
    organization.staff? ? "datacentred" : "#{organization.reference}_#{name}"
  end

  def keystone_params
    { name: reference, enabled: true,
      description: "Customer: #{organization.name}, Project: #{name}" 
    }
  end

  def ceph_params
    { 'uid' => uuid, 'display-name' => name}
  end

end