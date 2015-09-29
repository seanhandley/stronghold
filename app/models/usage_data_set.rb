class UsageDataMonthSet
  attr_reader :organization, :usage_data, :from_date, :to_date

  def initialize(organization, year, month)
    @organization = organization
    @from_date = from_date
    @to_date = to_date
  end

  def +(other)
    
  end

  def usage_data
    Rails.cache.fetch(key, expires_in: 6.months) do
      build_data_from_fresh
    end
  end

  def key
    "org#{organization.id}_#{from_date.strftime(timestamp_format)}_#{to_date.strftime(timestamp_format)}"
  end

  private

  def build_data_from_fresh
    organization.tenants.inject({}) do |acc, tenant|
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

  def timestamp_format
    "%Y%m%d%H"
  end
end