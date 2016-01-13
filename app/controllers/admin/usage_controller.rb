class Admin::UsageController < AdminBaseController

  before_filter :get_organizations_and_projects

  def index
    reset_dates
  end

  def create
    begin
      @from_date, @to_date = parse_dates create_params
      @total_hours = ((@to_date - @from_date) / 1.hour).round
      if ((@organization = Organization.find(create_params[:organization])) &&
          (@project      = Tenant.find(create_params[:project])))
        @usage_decorator = UsageDecorator.new(@organization)
        @usage_decorator.remove_cached_data(@from_date, @to_date) if create_params[:clear_cache]
        @usage = @usage_decorator.usage_data(from_date: @from_date, to_date: @to_date)
        @grand_total = @usage_decorator.grand_total

        @usage.each do |project, results|
          if @project.id == project.id
            @instance_usage = results[:instance_usage]
            @volume_usage = results[:volume_usage]
            @image_usage = results[:image_usage]
            @floating_ip_results = results[:floating_ip_results]
            @ip_quota_usage = results[:ip_quota_usage]
            @external_gateway_results = results[:external_gateway_results]
            @object_storage_usage = results[:object_storage_usage]
          end
        end
        @active_vouchers = @organization.active_vouchers(@from_date, @to_date)
      end
      render :report
    rescue ArgumentError => error
      flash.now[:alert] = error.message
      notify_honeybadger(error)
      reset_dates
      render :index
    end
  end

  private

  def create_params
    params.permit(:organization, :project, :clear_cache, :from => datetime_array, :to => datetime_array)
  end

  def get_organizations_and_projects
    @organizations ||= Organization.billable.collect{|organization| [organization.name, organization.id]}
    @projects ||= Organization.billable.map(&:tenants).flatten.collect{|tenant| [tenant.name, tenant.id, class: "#{tenant.organization.id}"]}
  end

  def datetime_array
    (1..5).map{|index| "(#{index}i)"}
  end

  def parse_dates(params)
    from, to = [:from, :to].collect do |key|
      begin
        DateTime.civil(*params[key].sort.map(&:last).map(&:to_i))
      rescue ArgumentError
        raise ArgumentError, "The #{key.to_s} date is not a valid date"
      end
    end.collect{|date| Time.zone.parse(date.to_s)}

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