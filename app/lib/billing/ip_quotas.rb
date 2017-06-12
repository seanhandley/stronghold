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

    def self.usage(project, from, to)      
      changes = Billing::IpQuota.where(:recorded_at => from..to,
                                       :project_id => project.uuid)
                                .order('recorded_at')
                                .map do |ipq|
        {
          previous:    ipq.previous,
          quota:       ipq.quota,
          recorded_at: ipq.recorded_at
        }
      end
      ipqh = ip_quota_hours(project, changes, from, to)
      {
        current_quota: project.quota_set['network']['floatingip'].to_i,
        quota_changes: changes,
        usage: [
          {
            value: ipqh,
            unit: 'hours',
            cost: {
              currency: 'gbp',
              value: (ipqh * RateCard.ip_address).nearest_penny.round(2),
              rate: RateCard.ip_address
            }
          }
        ]
      }
    end

    private

    def self.ip_quota_hours(project, results, from, to)
      results = results || []
      if results.none?
        quota = [project.quota_set['network']['floatingip'].to_i - 1, 0].max
        return (((to - from) / 60.0) / 60.0).round * quota
      else
        start = from
        hours = results.collect do |quota|
          period = (((quota[:recorded_at] - start) / 60.0) / 60.0).round
          start = quota[:recorded_at]
          q = quota[:previous] ? quota[:previous] : 1
          (q - 1) * period
        end.sum

        q = [(results.last[:quota] || 1) - 1, 0].max
        period = (((to - results.last[:recorded_at]) / 60.0) / 60.0).round
        hours += (q * period)
        return hours
      end
    end

  end
end
