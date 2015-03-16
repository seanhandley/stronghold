class Support::UsageController < SupportBaseController
  include UsageHelper

  before_filter -> { authorize! :read, :usage }
  before_filter :get_time_period

  def current_section
    'usage'
  end

  def index
    @usage = this_months_usage
    @usage_nav = usages_for_select(current_user.organization)
  end

  private

  def this_months_usage
    current_user.organization.tenants.inject({}) do |acc, tenant|
      acc[tenant] = {
        instance_results: Billing::Instances.usage(tenant.uuid, @from_date, @to_date),
        volume_results: Billing::Volumes.usage(tenant.uuid, @from_date, @to_date),
        image_results: Billing::Images.usage(tenant.uuid, @from_date, @to_date),
        floating_ip_results: Billing::FloatingIps.usage(tenant.uuid, @from_date, @to_date),
        ip_quota_results: Billing::IpQuotas.usage(tenant.uuid, @from_date, @to_date),
        external_gateway_results: Billing::ExternalGateways.usage(tenant.uuid, @from_date, @to_date),
        object_storage_results: Billing::StorageObjects.usage(tenant.uuid, @from_date, @to_date)
      }
      acc
    end
  end

  def get_time_period
    if params[:month] && params[:year]
      month = Time.parse("#{params[:year]}-#{params[:month]}-01 00:00:00")
      if month > current_user.organization.created_at && month < Time.zone.now.end_of_month
        @from_date = month.beginning_of_month
        @to_date = (month.end_of_month < Time.zone.now) ? month.end_of_month : Time.zone.now
      else
        @from_date = Time.zone.now.beginning_of_month
        @to_date = Time.zone.now
      end
    else
      @from_date = Time.zone.now.beginning_of_month
      @to_date = Time.zone.now
    end
    @total_hours = ((@to_date - @from_date) / 1.hour).ceil
  end

end
