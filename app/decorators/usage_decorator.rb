class UsageDecorator < ApplicationDecorator
  attr_reader :from_date, :to_date

  def latest_usage_data(from=Time.now.beginning_of_month, to=Time.now, count=0)
    @from_date, @to_date = from, to
    return usage_data(from_date: from, to_date: to) if count > 20
    key = "org#{model.id}_#{from.strftime(timestamp_format)}_#{to.strftime(timestamp_format)}"
    Rails.cache.exist?(key) ? Rails.cache.fetch(key) : latest_usage_data(from, to - 1.hour, count + 1)
  end

  def remove_cached_data(from_date, to_date)
    Rails.cache.delete("org#{model.id}_#{from_date.strftime(timestamp_format)}_#{to_date.strftime(timestamp_format)}")
  end

  def usage_data(args=nil)
    if args && args[:from_date] && args[:to_date]
      @usage_data = nil
      @from_date, @to_date = args[:from_date], args[:to_date]
    end
    raise(ArgumentError, 'Please supply :from_date and :to_date') unless from_date && to_date
    @usage_data ||= Rails.cache.fetch("org#{model.id}_#{from_date.strftime(timestamp_format)}_#{to_date.strftime(timestamp_format)}", expires_in: 30.days) do
      model.projects.with_deleted.where("created_at < ?", to_date).select{|t| t.deleted_at.nil? || t.deleted_at > from_date}.inject({}) do |acc, project|
        ip_quota_usage = Billing::IpQuotas.usage(project.uuid, from_date, to_date)
        acc[project] = {
          instance_usage: Billing::Instances.usage(project.uuid, from_date, to_date),
          volume_usage: Billing::Volumes.usage(project.uuid, from_date, to_date),
          image_usage: Billing::Images.usage(project.uuid, from_date, to_date),
          ip_quota_usage: ip_quota_usage,
          ip_quota_hours: ip_quota_hours(project, ip_quota_usage),
          object_storage_usage: Billing::StorageObjects.usage(project.uuid, from_date, to_date),
          current_ip_quota: project.quota_set['network']['floatingip'].to_i,
          ip_quota_total: ip_quota_cost(project, ip_quota_usage).nearest_penny,
          load_balancer_usage: Billing::LoadBalancers.usage(project.uuid, from_date, to_date),
          vpn_connection_usage: Billing::VpnConnections.usage(project.uuid, from_date, to_date)
        }
        acc
      end
    end
  end

  def instance_total(project_id, flavor_id=nil)
    usage_data.each do |project, results|
      if(project_id == project.id)
        results = results[:instance_usage]
        if flavor_id
          results = results.select{|i| i[:flavor][:flavor_id] == flavor_id}
        end
        return results.collect{|i| i[:cost]}.sum
      end
    end
    return 0
  end

  def volume_total(project_id)
    usage_data.each do |project, results|
      if(project_id == project.id)
        return results[:volume_usage].collect{|i| i[:cost]}.sum
      end
    end
    return 0
  end

  def image_total(project_id)
    usage_data.each do |project, results|
      if(project_id == project.id)
        return results[:image_usage].collect{|i| i[:cost]}.sum
      end
    end
    return 0
  end

  def load_balancer_total(project_id)
    usage_data.each do |project, results|
      if(project_id == project.id)
        return results[:load_balancer_usage]&.collect{|i| i[:cost]}&.sum || 0
      end
    end
    return 0
  end

  def vpn_connection_total(project_id)
    usage_data.each do |project, results|
      if(project_id == project.id)
        return results[:vpn_connection_usage]&.collect{|i| i[:cost]}&.sum || 0
      end
    end
    return 0
  end

  def ip_quota_total(project_id)
    usage_data.each do |project, results|
      if(project_id == project.id)
        return ip_quota_cost(project, results[:ip_quota_usage]).nearest_penny
      end
    end
    return 0
  end

  def ip_quota_hours(project, results)
    results = results || []
    if results.none?
      quota = [project.quota_set['network']['floatingip'].to_i - 1, 0].max
      return (((to_date - from_date) / 60.0) / 60.0).round * quota
    else
      start = from_date
      hours = results.collect do |quota|
        period = (((quota.recorded_at - start) / 60.0) / 60.0).round
        start = quota.recorded_at
        q = quota.previous ? quota.previous : 1
        (q - 1) * period
      end.sum

      q = [(results.last.quota || 1) - 1, 0].max
      period = (((to_date - results.last.recorded_at) / 60.0) / 60.0).round
      hours += (q * period)
      return hours
    end
  end

  def ip_quota_cost(project, results)
    ip_quota_hours(project, results) * RateCard.ip_address
  end

  def object_storage_total(project_id)
    usage_data.each do |project, results|
      if(project_id == project.id)
        return (results[:object_storage_usage] * RateCard.object_storage).nearest_penny
      end
    end
    return 0
  end

  def total(project_id)
    [
      instance_total(project_id), volume_total(project_id),
      image_total(project_id),
      ip_quota_total(project_id), 
      object_storage_total(project_id),
      load_balancer_total(project_id),
      vpn_connection_total(project_id)
    ].sum
  end

  def sub_total
    model.projects.with_deleted.collect{|t| total(t.id)}.sum
  end

  def discounts?
    !!active_discount
  end

  def discount_percent
    active_discount ? active_discount.voucher.discount_percent : 0.0
  end

  def active_discount
    model.active_vouchers(from_date, to_date).first
  end

  def tax_percent
    20
  end

  def grand_total
    return sub_total unless discounts?
    v = active_discount
    voucher_start = v.created_at
    voucher_end = v.expires_at

    totals = []
    
    # Calculate the part of the month that needs a discount
    from = (voucher_start < from_date) ? from_date : voucher_start
    to   = (voucher_end > to_date) ? to_date : voucher_end

    ud = UsageDecorator.new(model)

    ud.usage_data(from_date: from, to_date: to)
    discounted_total = ud.sub_total  * (1 - (discount_percent / 100.0))
    totals << discounted_total

    # Calculate the remainder at the start
    if from > from_date
      ud.usage_data(from_date: from_date, to_date: from)
      totals << ud.sub_total
    end

    # Calculate remainder at the end
    if to < to_date
      ud.usage_data(from_date: to, to_date: to_date)
      totals << ud.sub_total
    end

    totals.sum
  end

  def grand_total_plus_tax
    grand_total + (grand_total * 0.2)
  end

  private

  def timestamp_format
    "%Y%m%d%H"
  end
end