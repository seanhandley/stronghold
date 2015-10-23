require_relative './config/environment'

require 'ruby-prof'

# Profile the code
RubyProf.start

class UsageDecorator < ApplicationDecorator
  def cache
    @c ||= ActiveSupport::Cache::MemoryStore.new
  end
end

module Reports
  class UsageReport
    def contents
      return {} unless Organization.cloud.any?
      puts "Getting data for #{organizations.count} organizations"
      organizations.collect do |organization|
        puts organization.name
        puts '  -> Getting instance usage...'
        instances = organization.tenants.collect do |tenant|
          Billing::Instances.usage(tenant.uuid, from, to)
        end.flatten
        puts '  -> Getting volume usage...'
        volumes = organization.tenants.collect do |tenant|
          Billing::Volumes.usage(tenant.uuid, from, to)
        end.flatten
        puts '  -> Getting image usage...'
        images = organization.tenants.collect do |tenant|
          Billing::Images.usage(tenant.uuid, from, to)
        end.flatten
        puts '  -> Getting storage usage...'
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

    private

    def organizations
      Organization.where(test_account: false).includes(:tenants).select(&:cloud?)
    end
  end
end


from = (Time.zone.now - 1.day).beginning_of_week
to = (Time.zone.now - 1.day).end_of_week
Reports::UsageReport.new(from, to).contents

result = RubyProf.stop

# Print a flat profile to text
printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT)