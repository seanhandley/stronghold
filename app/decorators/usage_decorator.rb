class UsageDecorator < ApplicationDecorator
  def usage_data(from_date, to_date)
    format = "%Y%m%d%H%M%S"
    Rails.cache.fetch("org#{model.id}_#{from_date.strftime(format)}_#{to_date.strftime(format)}", expires_in: 1.hour) do
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
end