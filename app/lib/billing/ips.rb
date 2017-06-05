module Billing
  module Ips

    def self.sync!(from, to, sync)
      Billing.fetch_all_samples("ip.floating", from, to).each do |project_id, samples|
        record_ownerships("ip.floating", project_id, samples, sync)
      end
      Billing.fetch_all_samples("router", from, to).each      do |project_id, samples|
        record_ownerships("router",      project_id, samples, sync)
      end
    end

    def self.record_ownerships(ip_type, project_id, samples, sync)
      samples.each do |sample|
        meta_data = sample['resource_metadata']
        if ip_type == 'router'
          if ["router.create.end", "router.update.end"].include? meta_data['event_type']
            if ip_info = meta_data["external_gateway_info.external_fixed_ips"]
              ips = JSON.parse(ip_info.gsub("'","\""))
              if ips.any?
                Billing::Ip.create project_id: project_id,
                                   ip_id: sample['resource_id'],
                                   ip_type: ip_type,
                                   address: ips[0]['ip_address'],
                                   recorded_at: Time.zone.parse("#{sample['recorded_at']} UTC"),
                                   message_id: sample['message_id'],
                                   sync_id: sync.id,
                                   user_id: sample['user_id']
              end
            end
          end
        elsif ip_type == 'ip.floating'
          if ["floatingip.update.end", "floatingip.create.end"].include? meta_data['event_type']
            Billing::Ip.create project_id: project_id,
                               ip_id: sample['resource_id'],
                               ip_type: ip_type,
                               address: meta_data['floating_ip_address'],
                               recorded_at: Time.zone.parse("#{sample['recorded_at']} UTC"),
                               message_id: sample['message_id'],
                               sync_id: sync.id,
                               user_id: sample['user_id']
          end
        end
      end
    end

    def self.ownerships(ip_address, from, to)
      ips = Billing::Ip.where(address: ip_address,
                        recorded_at: (from..to))
      if ips.none?
        ips = [Billing::Ip.where(address: ip_address).order('recorded_at').last].compact
      end
      ips
    end

  end
end