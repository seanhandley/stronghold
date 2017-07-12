module UsageInformation

  #["total_memory_mb_usage", "total_vcpus_usage", "start", "tenant_id", "stop", "server_usages", "total_hours", "total_local_gb_usage"]
  def monthly_vcpu_hours
    compute_usage_previous_month.collect{|u| u["total_vcpus_usage"]}.sum.round(2)
  end

  def weekly_vcpu_hours
    compute_usage_previous_week.collect{|u| u["total_vcpus_usage"]}.sum.round(2)
  end

  def monthly_ram_tbh
    compute_usage_previous_month.collect{|u| (u["total_memory_mb_usage"] / (1024**2).to_f) / hours_in_previous_month}.sum.round(5)
  end

  def weekly_ram_tbh
    compute_usage_previous_week.collect{|u| (u["total_memory_mb_usage"] / (1024**2).to_f) / hours_in_previous_week}.sum.round(5)
  end

  def monthly_openstack_storage_tbh
    compute_usage_previous_month.collect{|u| (u["total_local_gb_usage"] / 1024.0) / hours_in_previous_month}.sum.round(5)
  end

  def weekly_openstack_storage_tbh
    compute_usage_previous_week.collect{|u| (u["total_local_gb_usage"] / 1024.0) / hours_in_previous_week}.sum.round(5)
  end

  def monthly_ceph_storage_tbh
    projects.map{|t| Billing::StorageObjects.usage(t.uuid, *last_month)[:usage].sum{|u| u[:value]}}.sum.round(5)
  end

  def weekly_ceph_storage_tbh
    projects.map{|t| Billing::StorageObjects.usage(t.uuid, *last_week)[:usage].sum{|u| u[:value]}}.sum.round(5)
  end

  def monthly_usage_value
    0
  end

  def discount_end_date
    vouchers = active_vouchers(Time.now-3.month, Time.now)
    vouchers.any? ? vouchers.first.expires_at.to_date : nil
  end

  def usage_types
    Rails.cache.fetch("usage_types_#{id}", expires_in: 1.day) do
      projects.map do |p|
        [
          Billing::InstanceState.joins(:billing_instance).where("billing_instances.project_id = ?", p.uuid).any? ? 'Compute'        : nil,
          Billing::VolumeState.joins(:billing_volume).where("billing_volumes.project_id = ?",       p.uuid).any? ? 'Volume'         : nil,
          Billing::ImageState.joins(:billing_image).where("billing_images.project_id = ?",          p.uuid).any? ? 'Image'          : nil,
          Billing::LoadBalancer.where(project_id: p.uuid).any?                                                   ? 'Load Balancer'  : nil,
          Billing::ObjectStorage.where(project_id: p.uuid).any?{|o| o.size > 0}                                  ? 'Object Storage' : nil,
          Billing::VpnConnection.where(project_id: p.uuid).any?                                                  ? 'VPN'            : nil
        ]
      end.flatten.compact.uniq.join(", ")
    end
  end

  def most_recent_usage_recorded_at
    Rails.cache.fetch("most_recent_usage_recorded_at_#{id}", expires_in: 1.day) do
      projects.map do |p|
        [
          Billing::InstanceState.joins(:billing_instance).where("billing_instances.project_id = ?", p.uuid).last&.recorded_at,
          Billing::VolumeState.joins(:billing_volume).where("billing_volumes.project_id = ?",       p.uuid).last&.recorded_at,
          Billing::ImageState.joins(:billing_image).where("billing_images.project_id = ?",          p.uuid).last&.recorded_at,
          Billing::LoadBalancer.where(project_id: p.uuid).last&.created_at,
          Billing::VpnConnection.where(project_id: p.uuid).last&.created_at
        ]
      end.flatten.compact.max
    end
  end

  private

  def last_week
    [(Time.now - 1.week).beginning_of_week, (Time.now - 1.week).end_of_week]
  end

  def last_month
    [(Time.now - 1.month).beginning_of_month, (Time.now - 1.month).end_of_month]
  end

  def hours_in_previous_week
    from, to = last_week
    (to - from) / 3600.0
  end

  def hours_in_previous_month
    from, to = last_month
    (to - from) / 3600.0
  end

  def compute_usage_previous_week
    project_usage(*last_week)
  end

  def compute_usage_previous_month
    project_usage(*last_month)
  end

  def project_usage(from, to)
    OpenStackConnection.usage(from,to).select{|u| projects.map(&:uuid).include?(u['tenant_id'])}
  rescue StandardError => e
    Honeybadger.notify(e)
    []
  end

end