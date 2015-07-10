class UsageDecorator < ApplicationDecorator
  attr_reader :from_date, :to_date
  def usage_data(args=nil)
    if args && args[:from_date] && args[:to_date]
      @from_date, @to_date = args[:from_date], args[:to_date]
    end
    raise(ArgumentError, 'Please supply :from_date and :to_date') unless from_date && to_date
    Rails.cache.fetch("org#{model.id}_#{from_date.strftime(timestamp_format)}_#{to_date.strftime(timestamp_format)}", expires_in: 1.hour) do
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
        if flavor_id
          results = results[:instance_results].select{|i| i[:flavor][:flavor_id] == flavor_id}
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

  # def ip_quota_total(tenant_id)
  #   usage_data.each do |tenant, results|
  #     if(tenant_id == tenant.id)
  #       return results[:ip_quota_results].collect{|i| i[:cost]}.sum
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

  def object_storage_total
    (results[:object_storage_results] * RateCard.object_storage).nearest_penny
  end

  def total(tenant_id)
    [
      instance_total(tenant_id), volume_total(tenant_id),
      image_total(tenant_id),
      # floating_ip_total(tenant_id),
      # ip_quota_total(tenant_id), external_gateway_total(tenant_id),
      object_storage_total
    ].sum
  end

  def grand_total
    model.tenants.sum{|t| total(t.id)}
  end

  private

  def timestamp_format
    "%Y%m%d%H"
  end
end