module Billing
  module VpnConnections

    def self.sync!(from, to, sync)
      Rails.cache.delete("active_vpn_connections")
      Project.with_deleted.each do |project|
        next unless project.uuid
        Billing.fetch_samples(project.uuid, "network.services.vpn.connections.create", from, to).each do |vpn_connection_id, samples|
          create_new_vpn_connection(project.uuid, vpn_connection_id, samples, sync)
        end
      end
    end

    def self.usage(project_id, from, to)
      vpns = Billing::VpnConnection.where(project_id: project_id)
      vpns.reject(&:terminated_at).each do |vpn|
        unless active_vpn_connections.include?(vpn.vpn_connection_id)
          vpn.update_columns terminated_at: Time.now
        end
      end
      vpns = vpns.select do |vpn|
        (!vpn.terminated_at && (vpn.started_at < to)) || (vpn.terminated_at && (vpn.terminated_at < to && vpn.terminated_at > from) && (vpn.started_at < to && vpn.started_at > from))
      end
      vpns.collect do |vpn|
        start  = [vpn.started_at, from].max
        finish = vpn.terminated_at ? [vpn.terminated_at, to].min : to
        hours = ((finish - start) / (60 ** 2)).ceil
        {
          vpn_connection_id: vpn.vpn_connection_id,
          name:  vpn.name,
          started_at: vpn.started_at,
          terminated_at: vpn.terminated_at,
          hours: hours,
          cost:  (hours * RateCard.vpn_connection).nearest_penny,
          owner: vpn.user_id
        }
      end
    end

    def self.active_vpn_connections
      Rails.cache.fetch("active_vpn_connections", expires: 10.minutes) do
        OpenStackConnection.network.ipsec_site_connections.map(&:id)
      end
    end


    def self.create_new_vpn_connection(project_id, vpn_connection_id, samples, sync)
      first_sample = samples[0]
      VpnConnection.create vpn_connection_id: vpn_connection_id, project_id: project_id,
                          started_at: first_sample['recorded_at'],
                          name: first_sample['resource_metadata']['name'],
                          sync_id: sync.id,
                          user_id: first_sample['user_id']
    end

  end
end
