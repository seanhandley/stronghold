class UsageDataSet
  attr_reader :organization, :usage_data, :month, :year

  def initialize(organization, year, month)
    @organization = organization
    @month = month
    @year = year
  end

  def usage_data
    this_month = Rails.cache.read(org_index_key)[org_month_key]
    merge_usage_data(this_month.collect{|entry_key| Rails.cache.read(entry_key)})
  end

  private

  def org_index_key
    "org#{organization.id}_usage_index"
  end

  def org_usage_key(new_uuid)
    "org#{organization.id}_usage_#{new_uuid}"
  end

  def org_month_key
    "#{year}-#{month}"
  end

  def org_index
    Rails.cache.fetch(org_index_key, expires_in: 6.months) do
      {}
    end
  end

  def update_org_index(new_key)
    index = Rails.cache.read(org_index_key)
    this_months_entry = index[org_month_key]
    this_months_entry = this_months_entry.to_a << new_key
    Rails.cache.write(org_index_key, this_months_entry, expires_in: 6.months)
  end

  def merge_usage_data(entries)
    int = nil
    string = nil
    datetime = nil
    float = nil
    ip_quota_objects = nil
    {
      instance_results: [
        {
          billable_seconds: int,
          uuid: string,
          name: string,
          tenant_id: string,
          first_booted_at: datetime,
          latest_state: string,
          terminated_at: datetime,
          rate: float,
          billable_hours: int,
          cost: float,
          arch: string,
          flavor: {
            flavor_id: string,
            name: string,
            vcpus_count: int,
            ram_mb: int,
            root_disk_gb: int,
            rate: float
          },
          image: {
            image_id: string,
            name: string
          }
        }
      ],
      volume_results: [
        { 
          terabyte_hours: float,
          cost: float,
          id: string,
          created_at: datetime,
          deleted_at: datetime,
          latest_size: float,
          name: string
        }
      ],
      image_results: [
        {
          terabyte_hours: float,
          cost: float,
          id: string,
          created_at: datetime,
          deleted_at: datetime,
          latest_size: float,
          name: string
        }
      ],
      floating_ip_results: [
        {
          billable_seconds: int,
          address: string,
          quota: int
        }
      ],
      ip_quota_results: [ip_quota_objects],
      external_gateway_results: [
        {
          billable_seconds: int,
          id: string,
          name: string
        }
      ],
      object_storage_results: float
    }
  end

  def timestamp_format
    "%Y%m%d%H"
  end
end