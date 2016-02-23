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

        vcpu_hours   = instances.collect {|i| i[:billable_hours] * i[:flavor][:vcpus_count]}.sum
        ram_tb_hours = instances.collect {|i| ((i[:flavor][:ram_mb] / 1024.0) / 1024.0) * i[:billable_hours]}.sum

        volumes_tb_hours = volumes.collect{|i| i[:terabyte_hours]}.sum
        images_tb_hours = images.collect{|i| i[:terabyte_hours]}.sum
        instances_disk_tb_hours = instances.collect {|i| i[:billable_hours] * (i[:flavor][:root_disk_gb] / 1024.0)}.sum
        openstack_tb_hours = volumes_tb_hours + images_tb_hours + instances_disk_tb_hours

        ceph_tb_hours  = objects.sum

        result = {
          :name => organization.name,
          :contacts => organization.admin_users.collect(&:email),
          :vcpu_hours => vcpu_hours,
          :ram_tb_hours => ram_tb_hours,
          :openstack_tb_hours => openstack_tb_hours,
          :ceph_tb_hours => ceph_tb_hours,
          :paying => organization.paying?,
          :spend => [instances, volumes, images].map{|i| i.map{|j| j[:cost]}}.flatten.compact.sum
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
  end
end
