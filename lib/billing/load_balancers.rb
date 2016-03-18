module Billing
  module LoadBalancers

    def self.sync!(from, to, sync)
      Rails.cache.delete("active_load_balancers")
      Project.with_deleted.each do |project|
        next unless project.uuid
        Billing.fetch_samples(project.uuid, "network.services.lb.pool.create", from, to).each do |lb_id, samples|
          create_new_lb(project.uuid, lb_id, samples, sync)
        end
      end
    end

    def self.usage(project_id, from, to)
      lbs = Billing::LoadBalancer.where(project_id: project_id)
      lbs.reject(&:terminated_at).each do |lb|
        unless active_load_balancers.include?(lb.lb_id)
          lb.update_columns terminated_at: Time.now
        end
      end
      lbs = lbs.select do |lb|
        !lb.terminated_at || (lb.terminated_at < to && lb.terminated_at > from) || (lb.started_at < to && lb.started_at > from)
      end
      lbs.collect do |lb|
        start  = [lb.started_at, from].max
        finish = lb.terminated_at ? [lb.terminated_at, to].min : to
        hours = ((finish - start) / (60 ** 2)).ceil
        {
          lb_id: lb.lb_id,
          name:  lb.name,
          started_at: lb.started_at,
          terminated_at: lb.terminated_at,
          hours: hours,
          cost:  (hours * RateCard.lb_pool).nearest_penny
        }
      end
      lbs.select{|lb| lb[:hours] && lb[:hours] > 0 }
    end

    def self.active_load_balancers
      Rails.cache.fetch("active_load_balancers", expires: 10.minutes) do
        OpenStackConnection.network.list_lb_pools.body['pools'].map{|lb| lb['id']}
      end
    end


    def self.create_new_lb(project_id, lb_id, samples, sync)
      first_sample = samples[0]
      LoadBalancer.create lb_id: lb_id, project_id: project_id,
                          started_at: first_sample['recorded_at'],
                          name: first_sample['resource_metadata']['name'],
                          sync_id: sync.id
    end

  end
end
