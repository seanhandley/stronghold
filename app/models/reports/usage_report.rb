module Reports
  class UsageReport

    attr_reader :from, :to

    def initialize(from, to)
      @from, @to = from, to
    end

    def contents
      return {} unless Organization.cloud.any?
      Organization.active.select(&:cloud?).reject(&:test_account).collect do |organization|
        instances = organization.tenants.collect do |tenant|
          Billing::Instances.usage(tenant.uuid, from, to)
        end.flatten

        volumes = organization.tenants.collect do |tenant|
          Billing::Volumes.usage(tenant.uuid, from, to)
        end.flatten

        images = organization.tenants.collect do |tenant|
          Billing::Images.usage(tenant.uuid, from, to)
        end.flatten

        objects = organization.tenants.collect do |tenant|
          Billing::StorageObjects.usage(tenant.uuid, from, to)
        end.flatten

        vcpu_seconds   = instances.collect {|i| i[:billable_seconds] * i[:flavor][:vcpus_count]}.sum
        ram_tb_seconds = instances.collect {|i| ((i[:flavor][:ram_mb] / 1024.0) / 1024.0) * i[:billable_seconds]}.sum

        volumes_tb_hours = volumes.collect{|i| i[:terabyte_hours]}.sum
        images_tb_hours = images.collect{|i| i[:terabyte_hours]}.sum
        instances_disk_tb_hours = instances.collect {|i| ((i[:billable_seconds] / 60.0) / 60.0) * (i[:flavor][:root_disk_gb] / 1024.0)}.sum
        openstack_tb_hours = volumes_tb_hours + images_tb_hours + instances_disk_tb_hours

        ceph_tb_hours  = objects.sum

        {
          :name => organization.name,
          :contacts => organization.admin_users.collect(&:email),
          :vcpu_hours => ((vcpu_seconds / 60.0) / 60.0),
          :ram_tb_hours => ((ram_tb_seconds / 60.0) / 60.0),
          :openstack_tb_hours => openstack_tb_hours,
          :ceph_tb_hours => ceph_tb_hours,
          :paying => organization.paying?,
          :spend => [instances, volumes, images].map{|i| i.map{|j| j[:cost]}}.flatten.compact.sum
        }
      end.sort{|x,y| y[:spend] <=> x[:spend]}.take(30)
    end
  end
end
