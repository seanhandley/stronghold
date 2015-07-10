class UsageDecorator < ApplicationDecorator
  attr_reader :from_date, :to_date
  def usage_data(args=nil)
    if args[:from_date] && args[:to_date]
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

  def instance_total(flavour=nil)
    
  end

  def volume_total
    
  end

  def image_total
    
  end

  def floating_ip_total
    
  end

  def ip_quota_total
    
  end

  def external_gateway_total
    
  end

  def object_storage_total
    
  end

  def grand_total
    
  end

  private

  def timestamp_format
    "%Y%m%d%H"
  end
end