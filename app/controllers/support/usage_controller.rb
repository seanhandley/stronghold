class Support::UsageController < SupportBaseController
  include UsageHelper
  include TimePeriodHelper

  before_filter -> { authorize! :read, :usage }
  before_filter :get_time_period_from_params

  def current_section
    'usage'
  end

  def index
    @usage = this_months_usage
    @usage_nav = usages_for_select(current_user.organization)
  end

  private

  def this_months_usage
    @active_vouchers = current_user.organization.active_vouchers(@from_date, @to_date)
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

  def get_time_period_from_params
    @from_date, @to_date = get_time_period(params[:year], params[:month])
    @total_hours = ((@to_date - @from_date) / 1.hour).ceil
  end

end
