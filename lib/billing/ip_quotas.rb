module Billing
  module IpQuotas

    def self.sync!(sync)
      Tenant.with_deleted.each do |tenant|
        next unless tenant.uuid
        quota = tenant.quota_set['network']['floatingip'].to_i
        latest = Billing::IpQuota.where(tenant_id: tenant.uuid).order('recorded_at').last
        # Only store if there's been a change
        if !latest || latest.quota != quota
          Billing::IpQuota.create(tenant_id: tenant.uuid,
                                  previous: latest ? latest.quota : nil,
                                  quota: quota,
                                  recorded_at: Time.zone.now,
                                  billing_sync: sync)
        end
      end
    end

    def self.usage(tenant_id, from, to)
      Billing::IpQuota.where(:recorded_at => from..to,
                              :tenant_id => tenant_id).order('recorded_at')
    end

  end
end
