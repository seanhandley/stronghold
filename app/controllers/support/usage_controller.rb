class Support::UsageController < SupportBaseController
  include UsageHelper

  before_filter -> { authorize! :read, :usage }
  before_filter :get_time_period_from_params

  def current_section
    'usage'
  end

  def index
    @usage = UsageDecorator.new(current_user.organization).usage_data(@from_date, @to_date)
    @active_vouchers = current_user.organization.active_vouchers(@from_date, @to_date)
    @usage_nav = usages_for_select(current_user.organization)
  end

  private

  def get_time_period_from_params
    @from_date, @to_date = get_time_period(params[:year], params[:month])
    @total_hours = ((@to_date - @from_date) / 1.hour).ceil
  end

end
