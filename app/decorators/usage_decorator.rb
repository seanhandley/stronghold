class UsageDecorator < ApplicationDecorator
  attr_reader :from_date, :to_date
  def usage_data(args=nil)
    if args && args[:from_date] && args[:to_date]
      @from_date, @to_date = args[:from_date], args[:to_date]
    end
    raise(ArgumentError, 'Please supply :from_date and :to_date') unless from_date && to_date
    Rails.cache.fetch("org#{model.id}_#{from_date.strftime(timestamp_format)}_#{to_date.strftime(timestamp_format)}", expires_in: 30.days) do
      model.tenants.inject({}) do |acc, tenant|
        acc[tenant] = {
          instance_results: Billing::Instances.usage(tenant.uuid, from_date, to_date),
          volume_results: Billing::Volumes.usage(tenant.uuid, from_date, to_date),
          image_results: Billing::Images.usage(tenant.uuid, from_date, to_date),
          floating_ip_results: Billing::FloatingIps.usage(tenant.uuid, from_date, to_date),
          ip_quota_results: Billing::IpQuotas.usage(tenant.uuid, from_date, to_date),
          external_gateway_results: Billing::ExternalGateways.usage(tenant.uuid, from_date, to_date),
          object_storage_results: Billing::StorageObjects.usage(tenant.uuid, from_date, to_date)
        }
        acc
      end
    end
  end

  def instance_total(tenant_id, flavor_id=nil)
    usage_data.each do |tenant, results|
      if(tenant_id == tenant.id)
        results = results[:instance_results]
        if flavor_id
          results = results.select{|i| i[:flavor][:flavor_id] == flavor_id}
        end
        return results.collect{|i| i[:cost]}.sum
      end
    end
  end

  def volume_total(tenant_id)
    usage_data.each do |tenant, results|
      if(tenant_id == tenant.id)
        return results[:volume_results].collect{|i| i[:cost]}.sum
      end
    end
  end

  def image_total(tenant_id)
    usage_data.each do |tenant, results|
      if(tenant_id == tenant.id)
        return results[:image_results].collect{|i| i[:cost]}.sum
      end
    end
  end

  # def floating_ip_total(tenant_id)
  #   usage_data.each do |tenant, results|
  #     if(tenant_id == tenant.id)
  #       return results[:floating_ip_results].collect{|i| i[:cost]}.sum
  #     end
  #   end
  # end

  # def external_gateway_total(tenant_id)
  #   usage_data.each do |tenant, results|
  #     if(tenant_id == tenant.id)
  #       return results[:external_gateway_results].collect{|i| i[:cost]}.sum
  #     end
  #   end
  # end

  def ip_quota_total(tenant_id)
    daily_rate = ((RateCard.ip_address * 12) / 365.0).round(2)
    usage_data.collect do |tenant, results|
      if(tenant_id == tenant.id)
        if results[:ip_quota_results].none?
          quota = Fog::Network.new(OPENSTACK_ARGS).get_quota(tenant.uuid).body['quota']['floatingip'] - 1
          ((((to_date - from_date) / 60.0) / 60.0) / 24.0).round * daily_rate * quota
        else
          start = from_date
          cost = results[:ip_quota_results].collect do |quota|
            period = ((((quota.recorded_at - start) / 60.0) / 60.0) / 24.0).round
            start = quota.recorded_at
            total_rate = (period * daily_rate)
            q = quota.previous ? quota.previous : 1
            (q - 1) * total_rate
          end.sum

          q = results[:ip_quota_results].last.quota - 1
          period = ((((to_date - results[:ip_quota_results].last.recorded_at) / 60.0) / 60.0) / 24.0).round
          total_rate = (period * daily_rate)
          cost += (q * total_rate)
          cost
        end
      end
    end.compact.sum
  end

  def object_storage_total(tenant_id)
    usage_data.each do |tenant, results|
      if(tenant_id == tenant.id)
        return (results[:object_storage_results] * RateCard.object_storage).nearest_penny
      end
    end
  end

  def total(tenant_id)
    [
      instance_total(tenant_id), volume_total(tenant_id),
      image_total(tenant_id),
      # floating_ip_total(tenant_id), external_gateway_total(tenant_id),
      ip_quota_total(tenant_id), 
      object_storage_total(tenant_id)
    ].sum
  end

  def sub_total
    model.tenants.collect{|t| total(t.id)}.sum
  end

  def discounts?
    !!active_discount
  end

  def discount_percent
    active_discount.voucher.discount_percent
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

  private

  def timestamp_format
    "%Y%m%d%H"
  end
end