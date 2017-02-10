module Billing
  module StorageObjects

    def self.sync!(sync)
      Project.includes(:organization => :products).with_deleted.each do |project|
        next unless project.uuid && project.organization && project.organization.storage?
        tb = Ceph::Usage.kilobytes_for(project.uuid)
        unless tb == 0 && Billing::ObjectStorage.where(:project_id => project.uuid).none?
          Billing::ObjectStorage.create(project_id: project.uuid,
                                        size: tb,
                                        recorded_at: Time.zone.now,
                                        billing_sync: sync)
        end
      end
    end

    def self.usage(project_id, from, to)
      measurements = Billing::ObjectStorage.where(:recorded_at => from..to,
                                                  :project_id => project_id).order('recorded_at')
      last = measurements.first
      gbs = measurements.collect do |measurement|
        
        gb = (measurement.size.to_f * 1024.0 / 1_000_000_000.0).ceil
        seconds = measurement.recorded_at - last.recorded_at
        last = measurement
        gb * seconds
      end.sum
      (gbs / 3_600_000.0).ceil
    end

  end
end
