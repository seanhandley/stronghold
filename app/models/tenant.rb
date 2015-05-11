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
    { name: reference, enabled: false,
      description: "Customer: #{organization.name}, Project: #{name}" 
    }
  end

  def ceph_params
    { 'uid' => uuid, 'display-name' => name}
  end

  def zero_quotas
    args = [
             {"cores"=>0,"injected_file_content_bytes"=>0, "injected_file_path_bytes"=>0,
              "injected_files"=>0, "instances"=>0, "key_pairs"=>0,
              "metadata_items"=>0, "ram"=>0},
    
             {"volumes"=>0, "snapshots"=>0, "gigabytes" => 0},
    
             {"floatingip"=>0, "security_group_rule"=>0, "security_group"=>0,
              "network"=>0,"port"=>0, "router"=>0, "subnet"=>0}
            ]
    
    set_quotas(*args)
  end

  def set_self_service_quotas
    args = [
             {"cores"=>2,"injected_file_content_bytes"=>10240, "injected_file_path_bytes"=>10240,
              "injected_files"=>5, "instances"=>2, "key_pairs"=>10,
              "metadata_items"=>128, "ram"=>1024},
    
             {"volumes"=>2, "snapshots"=>2, "gigabytes" => 20},
    
             {"floatingip"=>1, "security_group_rule"=>100, "security_group"=>10,
              "network"=>5,"port"=>20, "router"=>1, "subnet"=>5}
            ]
    
    set_quotas(*args)  
  end

  private

  def set_quotas(compute, volume, network)
    Fog::Compute.new(OPENSTACK_ARGS).update_quota id, compute
    Fog::Volume.new(OPENSTACK_ARGS).update_quota  id, volume
    Fog::Network.new(OPENSTACK_ARGS).update_quota id, network
    true
  end

end