class Reaper
  def ips
    @ips ||= OpenStackConnection.network.floating_ips
  end

  def routers
    @routers ||= OpenStackConnection.network.routers
  end

  def ports
    @ports ||= OpenStackConnection.network.ports
  end

  def projects
    @projects ||= OpenStackConnection.identity.projects
  end

  def instances
    @instances ||= OpenStackConnection.compute.list_servers_detail(all_tenants: true).body['servers']
  end

  def stuck_in_a_project
    # Find floating IPs assigned to a project but not to an instance
    ips.reject(&:port_id).map do |ip|
      {
        ip_id:     ip.id,
        tenant_id: ip.tenant_id,
        public_ip: ip.floating_ip_address
      }
    end.select do |ip|
      billing_ip = Billing::Ip.where(ip_id: ip[:ip_id]).order("recorded_at").last
      billing_ip && (billing_ip.recorded_at + 24.hours) < Time.now
    end.reject do |ip|
      organization_is_staff(ip[:tenant_id])
    end
  end

  def stuck_in_an_instance
    # Find floating IPs assigned to instances that are offline and haven't been online in a long time
    instances.select{|instance| instance['status'] != 'ACTIVE'}.map do |instance|
      if instance['addresses'].any?
        addresses = instance['addresses'].map do |_,addresses|
          addresses.select do |address|
            address['OS-EXT-IPS:type'] == 'floating'
          end
        end.flatten
        addresses.map do |address|
          {
            tenant_id:   instance['tenant_id'],
            public_ip:   address['addr'],
            instance_id: instance['id']
          }
        end
      else
        nil
      end
    end.flatten.compact.reject do |instance|
      organization_is_paying(instance[:tenant_id] ||
      organization_is_staff(instance[:tenant_id]
    end.map{|r| StuckIp.new r}
  end

  def dormant_routers
    # Find routers that belong to customers who've been inactive for over 3 months
    routers.select{|r| r.external_gateway_info}.reject do |router|
      (organization_is_paying(router.tenant_id) &&
      organization_is_active(router.tenant_id)) ||
      organization_is_staff(router.tenant_id)
    end.map do |router|
      router.external_gateway_info['external_fixed_ips'].map do |ip|
        {
          tenant_id:    router.tenant_id,
          public_ip:    ip['ip_address']
        }
      end
    end.flatten.compact.uniq{|ip| ip[:public_ip]}
  end

  def reap(dry_run=true)
    stuck_in_a_project.each do |ip|
      OpenStackConnection.network.delete_floating_ip(ip[:ip_id]) unless dry_run
      logger.info "Removed unused IP #{ip[:public_ip]} from tenant #{ip[:tenant_id]}"
    end
    organizations = dormant_routers.map do |router|
      project = Project.find_by_uuid(router[:tenant_id])
      project&.organization
    end.compact
    organizations.uniq.each do |organization|
      organization.transition_to!(:dormant) unless dry_run
      logger.info "Transitioning #{organization.name} (#{organization.reporting_code}) to dormant state"
    end
    true
  end

  def remove_stuck_ip_from_instance(instance_id, ip_address)
    OpenStackConnection.compute.servers.get(instance_id).disassociate_address(ip_address)
  end

  private

  def logger
    if Rails.env.production?
      ::Logger.new("/var/log/rails/stronghold/reaper.log")
    else
      Rails.logger
    end
  end

  def organization_is_paying(tenant_id)
    project = Project.find_by_uuid(tenant_id)
    return nil unless project
    project.organization.weekly_spend > 0
  end

  def organization_is_active(tenant_id)
    project = Project.find_by_uuid(tenant_id)
    return nil unless project
    (project.organization.most_recent_usage_recorded_at + 3.months) > Time.now
  end

  def organization_is_staff(tenant_id)
    project = Project.find_by_uuid(tenant_id)
    return nil unless project
    project.organization.staff?
  end
end
