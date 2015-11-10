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
    tenants.map{|t| Billing::StorageObjects.usage(t.uuid, *last_month)}.sum.round(5)
  end

  def weekly_ceph_storage_tbh
    tenants.map{|t| Billing::StorageObjects.usage(t.uuid, *last_week)}.sum.round(5)
  end

  def monthly_usage_value
    0
  end

  def discount_end_date
    # Needs to be a ruby date obj
    nil
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
    tenant_usage(*last_week)
  end

  def compute_usage_previous_month
    tenant_usage(*last_month)
  end

  def tenant_usage(from, to)
    OpenStackConnection.usage(from,to).select{|u| tenants.map(&:uuid).include?(u['tenant_id'])}
  end

end