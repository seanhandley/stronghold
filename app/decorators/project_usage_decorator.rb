class ProjectUsageDecorator < ApplicationDecorator
  attr_reader :year, :month

  def initialize(project, year, month)
    @year     = year
    @month    = month
    super(project)
  end

  def project
    model
  end

  def usage_data
    @usage_data ||= {
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

  def volume_total
    usage_data[:volume_usage].collect{|i| i[:cost]}.sum
  end

  def image_total
    usage_data[:image_usage].collect{|i| i[:cost]}.sum
  end

  def load_balancer_total
    usage_data[:load_balancer_usage].collect{|i| i[:cost]}.sum
  end

  def vpn_connection_total
    usage_data[:vpn_connection_usage].collect{|i| i[:cost]}.sum
  end

  def ip_quota_total(project_id)
    usage_data[:ip_quota_usage].collect{|i| i[:cost]}.sum
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
    usage_data[:object_storage_usage] * RateCard.object_storage).nearest_penny
  end

  def sub_total
    [
      instance_total, volume_total,
      image_total,
      ip_quota_total, 
      object_storage_total,
      load_balancer_total,
      vpn_connection_total
    ].sum
  end

  def discounts?
    !!active_discount
  end

  def discount_percent
    active_discount ? active_discount.voucher.discount_percent : 0.0
  end

  def active_discount
    model.organization.active_vouchers(from_date, to_date).first
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
end