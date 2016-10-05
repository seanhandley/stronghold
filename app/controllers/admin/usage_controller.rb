class Admin::UsageController < AdminBaseController
  include UsageHelper

  def show
    reset_dates
    @organization = Organization.find(params[:id])
  end

  def update
    begin
      @from_date, @to_date = parse_dates create_params
      @total_hours = ((@to_date - @from_date) / 1.hour).round
      if (@organization = Organization.find(params[:id]))
        @usage_decorator = UsageDecorator.new(@organization)
        @usage_decorator.remove_cached_data(@from_date, @to_date) if create_params[:clear_cache]
        @usage = @usage_decorator.usage_data(from_date: @from_date, to_date: @to_date)
        @grand_total = @usage_decorator.grand_total

        @active_vouchers = @organization.active_vouchers(@from_date, @to_date)
      end

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
      reset_dates
      render :show
    end
  end

  private

  def create_params
    params.permit(:organization, :clear_cache, :from => datetime_array, :to => datetime_array)
  end

  def datetime_array
    (1..5).map{|index| "(#{index}i)"}
  end

  def parse_dates(params)
    dates = [:from, :to].collect do |key|
      begin
        DateTime.civil(*params[key].sort.map(&:last).map(&:to_i))
      rescue ArgumentError
        raise ArgumentError, "The #{key.to_s} date is not a valid date"
      end
    end

    from, to = dates.collect{|date| Time.parse("#{date.year}-#{date.month}-#{date.day} #{date.hour}:#{date.minute}:#{date.second}")}

    if from < Billing::Sync.first.completed_at
      raise ArgumentError, "The earliest date we have usage for is #{Billing::Sync.first.completed_at}. Please ensure the start date is greater."
    end
    if to.utc > Time.now.utc
      raise ArgumentError, "The end date cannot be in the future"
    end
    if to <= from
      raise ArgumentError, "The start date must be later than the end date"
    end

    return [from, to]
  end

  def reset_dates
    now = Time.zone.now
    @from_date = now.last_month.beginning_of_month
    @from_date = Billing::Sync.first.completed_at if @from_date < Billing::Sync.first.completed_at
    @to_date = now.beginning_of_month
    @to_date = now if @to_date < @from_date
  end

end
