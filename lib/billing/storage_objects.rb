module Billing
  module StorageObjects

    def self.sync!(sync)
      Tenant.with_deleted.each do |tenant|
        next unless tenant.uuid && tenant.organization && tenant.organization.storage?
        tb = Ceph::Usage.kilobytes_for(tenant.uuid)
        Billing::ObjectStorage.create(tenant_id: tenant.uuid,
                                      size: tb,
                                      recorded_at: Time.zone.now,
                                      billing_sync: sync)
      end
    end

    def self.usage(tenant_id, from, to)
      measurements = Billing::ObjectStorage.where(:recorded_at => from..to,
                                                  :tenant_id => tenant_id).order('recorded_at')
      last = measurements.first
      gbs = measurements.collect do |measurement|
        
        gb = (measurement.size.to_f * 1024.0 / 1_000_000_000.0).ceil
        seconds = measurement.recorded_at - last.recorded_at
        last = measurement
        gb * seconds
      end.sum
      gbs / 3_600_000.0
    end

  end
end
