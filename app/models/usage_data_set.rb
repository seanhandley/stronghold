class UsageDataSet
  attr_reader :organization, :usage_data, :from_date, :to_date

  def initialize(organization, year, month)
    @organization = organization
    @from_date = from_date
    @to_date = to_date
  end

  def usage_data
    Rails.cache.fetch(key, expires_in: 6.months) do
      build_data_from_fresh
    end
  end

  private

  def org_index_key
    "org#{organization.id}_usage_index"
  end

  def org_usage_key(new_uuid)
    "org#{organization.id}_usage_#{new_uuid}"
  end

  def org_index
    Rails.cache.fetch(org_index_key, expires_in: 6.months) do
      []
    end
  end

  def update_org_index(new_key)
    index = Rails.cache.read(org_index_key)
    Rails.cache.write(org_index_key, index << new_key, expires_in: 6.months)
  end

  def build_data_from_fresh
    new_uuid = SecureRandom.hex
    usage_data = organization.tenants.inject({}) do |acc, tenant|
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
    Rails.cache.write(org_usage_key(new_uuid), expires_in: 6.months)
      {
        usage_data: usage_data,
        organization: organization,
        from_date: from_date,
        to_date: to_date,
        uuid: uuid
      }
    end
    update_org_index(org_usage_key(new_uuid))
  end

  def timestamp_format
    "%Y%m%d%H"
  end
end