module Billing
  module IpQuotas

    def self.sync!(sync)
      Project.with_deleted.each do |project|
        next unless project.uuid
        quota = project.quota_set['network']['floatingip'].to_i
        latest = Billing::IpQuota.where(project_id: project.uuid).order('recorded_at').last
        # Only store if there's been a change
        if !latest || latest.quota != quota
          Billing::IpQuota.create(project_id: project.uuid,
                                  previous: latest ? latest.quota : nil,
                                  quota: quota,
                                  recorded_at: Time.zone.now,
                                  billing_sync: sync)
        end
      end
    end

    def self.usage(project_id, from, to)
      Billing::IpQuota.where(:recorded_at => from..to,
                              :project_id => project_id).order('recorded_at')
    end

  end
end
