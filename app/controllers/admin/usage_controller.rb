module Admin
  class UsageController < AdminBaseController
    include UsageHelper

    def show
      @organization = Organization.find(params[:id])
      @usage_nav = usages_for_admin_select(@organization)
    end

    def update
      begin
        @year, @month = params[:month_year].split(",").map(&:to_i)
        @total_hours = ((to_date - from_date) / 1.hour).round
        if (@organization = Organization.find(params[:id]))
          @usage_decorator = UsageDecorator.new(@organization, @year, @month)
          @usage = @usage_decorator.usage_data
          @grand_total = @usage_decorator.grand_total

          @active_vouchers = @organization.active_vouchers(from_date, to_date)
        end

        @to_date, @from_date = to_date, from_date

        case params[:format].try :downcase
        when 'json'
          render json: usage_data_as_json(@usage, @usage_decorator.grand_total)
        when 'xml'
          render xml: usage_data_as_xml(@usage, @usage_decorator.grand_total)
        when 'csv'
          headers['Content-Type'] ||= 'text/csv'
          render text: usage_data_as_csv(@usage)
        else
          render :report
        end
      rescue ArgumentError => error
        flash.now[:alert] = error.message
        notify_honeybadger(error)
        render :show
      end
    end

    private

    def create_params
      params.permit(:organization, :year, :month)
    end

    def from_date
      Time.parse("#{@year}-#{@month}-01").beginning_of_month
    end

    def to_date
      [Time.now, from_date.end_of_month].min
    end

  end
end
