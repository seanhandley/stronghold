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

        vcpu_hours   = instances.sum {|i| i[:usage].sum {|usage| usage[:value] * usage[:meta][:flavor][:vcpus_count]}}
        ram_tb_hours = instances.sum {|i| i[:usage].sum {|usage| usage[:value] * ((usage[:meta][:flavor][:ram_mb] / 1024.0) / 1024.0)}}

        volumes_tb_hours = volumes.sum {|i| i[:usage].sum{|u| u[:value]}}
        images_tb_hours  = images.sum  {|i| i[:usage].sum{|u| u[:value]}}
        instances_disk_tb_hours = instances.sum {|i| i[:usage].sum {|usage| usage[:value] * (usage[:meta][:flavor][:root_disk_gb] / 1024.0)}}
        openstack_tb_hours = volumes_tb_hours + images_tb_hours + instances_disk_tb_hours

        ceph_tb_hours  = objects.sum{|o| o[:usage].sum{|usage| usage[:value]}}

        load_balancer_hours  = load_balancers.sum  {|i| i[:usage].sum{|u| u[:value]}}
        vpn_connection_hours = vpn_connections.sum {|i| i[:usage].sum{|u| u[:value]}}

        spend = [instances, volumes, images, load_balancers, vpn_connections, objects].sum{|i| i.sum{|j| j[:usage].sum{|u| u[:cost][:value]}}}

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
          :spend => spend
        }
        organization.update_attributes(weekly_spend: result[:spend])
        result
      end.sort{|x,y| y[:spend] <=> x[:spend]}.take(30)
    end
  end
end
