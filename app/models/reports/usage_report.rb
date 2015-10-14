module Reports
  class UsageReport

    attr_reader :from, :to

    def initialize(from, to)
      @from, @to = from, to
    end

    def contents
      return {} unless Organization.cloud.any?
      organizations.collect do |organization|
        tenants = organization.tenants

        instances = get_usage(Billing::Instances, tenants, from, to)
        volumes = get_usage(Billing::Volumes, tenants, from, to)
        images = get_usage(Billing::Images, tenants, from, to)
        objects = get_usage(Billing::StorageObjects, tenants, from, to)

        vcpu_hours, ram_tb_hours, instances_disk_tb_hours = instance_usage_aggregated_data(instances)
        volumes_tb_hours = volumes.collect{|volume| volume[:terabyte_hours]}.sum
        images_tb_hours = images.collect{|image| image[:terabyte_hours]}.sum

        openstack_tb_hours = volumes_tb_hours + images_tb_hours + instances_disk_tb_hours

        ceph_tb_hours  = objects.sum

        {
          :name => organization.name,
          :contacts => organization.admin_users.collect(&:email),
          :vcpu_hours => vcpu_hours,
          :ram_tb_hours => ram_tb_hours,
          :openstack_tb_hours => openstack_tb_hours,
          :ceph_tb_hours => ceph_tb_hours,
          :paying => organization.paying?,
          :spend => [instances, volumes, images].map{|usage| usage.map{|entry| entry[:cost]}}.flatten.compact.sum
        }
      end.sort{|x,y| y[:spend] <=> x[:spend]}.take(30)
    end

    private

    def organizations
      Organization.includes(:tenants).active.select(&:cloud?).reject(&:test_account)
    end

    def get_usage(klass, tenants, from, to)
      tenants.collect do |tenant|
        klass.usage(tenant.uuid, from, to)
      end.flatten
    end

    def instance_usage_aggregated_data(instances)
      vcpu_hours, ram_tb_hours, instances_disk_tb_hours  = [], [], []
      instances.each do |instance|
        billable_hours = instance[:billable_hours]
        vcpu_hours              << (billable_hours * instance[:flavor][:vcpus_count])
        ram_tb_hours            << (billable_hours * (instance[:flavor][:ram_mb] / 1_048_576.0))
        instances_disk_tb_hours << (billable_hours * (instance[:flavor][:root_disk_gb] / 1024.0))
      end
      
      [vcpu_seconds.sum, ram_tb_seconds.sum, instances_disk_tb_hours.sum]
    end
  end
end
