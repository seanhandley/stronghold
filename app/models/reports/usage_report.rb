module Reports
  class UsageReport

    attr_reader :from, :to

    def initialize(from, to)
      @from, @to = from, to
    end

    def contents
      return {} unless Organization.cloud.any?
      Organization.active.reject(&:test_account?).collect do |organization|
        instances = organization.projects.collect do |project|
          Billing::Instances.usage(project.uuid, from, to)
        end.flatten

        volumes = organization.projects.collect do |project|
          Billing::Volumes.usage(project.uuid, from, to)
        end.flatten

        images = organization.projects.collect do |project|
          Billing::Images.usage(project.uuid, from, to)
        end.flatten

        objects = organization.projects.collect do |project|
          Billing::StorageObjects.usage(project.uuid, from, to)
        end.flatten

        load_balancers = organization.projects.collect do |project|
          Billing::LoadBalancers.usage(project.uuid, from, to)
        end.flatten

        vpn_connections = organization.projects.collect do |project|
          Billing::VpnConnections.usage(project.uuid, from, to)
        end.flatten

        vcpu_hours   = instances.sum {|i| i[:billable_hours].sum {|flavor_id, hours| hours * instance_flavors[flavor_id][:vcpus_count]}}
        ram_tb_hours = instances.sum {|i| i[:billable_hours].sum {|flavor_id, hours| hours * ((instance_flavors[flavor_id][:ram_mb] / 1024.0) / 1024.0)}}

        volumes_tb_hours = volumes.collect{|i| i[:terabyte_hours]}.sum
        images_tb_hours  = images.collect {|i| i[:terabyte_hours]}.sum
        instances_disk_tb_hours = instances.sum {|i| i[:billable_hours].sum {|flavor_id, hours| hours * (instance_flavors[flavor_id][:root_disk_gb] / 1024.0)}}
        openstack_tb_hours = volumes_tb_hours + images_tb_hours + instances_disk_tb_hours

        ceph_tb_hours  = objects.sum
        ceph_cost = [{cost: ceph_tb_hours * RateCard.object_storage}]

        load_balancer_hours  = load_balancers.sum  {|i| i[:hours]}
        vpn_connection_hours = vpn_connections.sum {|i| i[:hours]}

        result = {
          :name => organization.name,
          :contacts => organization.admin_users.collect(&:email),
          :vcpu_hours => vcpu_hours,
          :ram_tb_hours => ram_tb_hours,
          :openstack_tb_hours => openstack_tb_hours,
          :ceph_tb_hours => ceph_tb_hours,
          :load_balancer_hours => load_balancer_hours,
          :vpn_connection_hours => vpn_connection_hours,
          :paying => organization.paying?,
          :spend => [instances, volumes, images, load_balancers, vpn_connections, ceph_cost].map{|i| i.map{|j| j[:cost]}}.flatten.compact.sum
        }
        organization.update_attributes(weekly_spend: result[:spend])
        result
      end.sort{|x,y| y[:spend] <=> x[:spend]}.take(30)
    end

    private

    def organizations
      Organization.includes(
      :projects => [
        :billing_storage_objects,
        :billing_ip_quotas,
        {
        billing_instances: :instance_states,
        billing_volumes: :volume_states,
        billing_images: :image_states,
      }]
    )
    end

    def instance_flavors
      @instance_flavors ||= Billing::InstanceFlavor.all.inject({}) do |acc, e|
        acc[e.flavor_id] = { vcpus_count: e.vcpus, root_disk_gb: e.disk, ram_mb: e.ram}
        acc
      end
    end
  end
end
