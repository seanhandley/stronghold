class Support::UsageController < SupportBaseController
  include UsageHelper

  before_filter -> { authorize! :read, :usage }
  before_filter :get_time_period_from_params

  def current_section
    'usage'
  end

  def index
    @usage_decorator = UsageDecorator.new(current_organization)
    if params[:year] && params[:month] && !((params[:year].to_i == Time.now.year) && (params[:month].to_i == Time.now.month))
      @usage = @usage_decorator.usage_data(from_date: @from_date, to_date: @to_date)
    else
      @usage = @usage_decorator.latest_usage_data
    end
    @usage = Hash[(@usage.map {|k,v| [(k.is_a?(Integer) || k.is_a?(String)) ? Tenant.find(k.to_i) : k), v]}]
    @active_vouchers = current_organization.active_vouchers(@from_date, @to_date)
    @usage_nav = usages_for_select(current_organization)
  end

  private

  def get_time_period_from_params
    @from_date, @to_date = get_time_period(params[:year], params[:month])
    @total_hours = ((@to_date - @from_date) / 1.hour).ceil
  end

end
