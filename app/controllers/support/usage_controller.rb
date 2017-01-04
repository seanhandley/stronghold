module Support
  class UsageController < SupportBaseController
    include UsageHelper

    before_action -> { authorize! :read, :usage }

    def current_section
      'usage'
    end

    def index
      @year  = (params[:year]  || Time.now.year).to_i
      @month = (params[:month] || Time.now.month).to_i

      @usage_decorator = UsageDecorator.new(current_organization, @year, @month)
      @usage = @usage_decorator.usage_data

      @from_date = Time.parse("#{@year}-#{@month}-01").beginning_of_month
      @to_date   = @from_date.end_of_month

      @active_vouchers = current_organization.active_vouchers(@from_date, @to_date)

      @usage_nav = usages_for_select(current_organization)
      @total_hours = (([@to_date, Time.now].min - @from_date) / 1.hour).ceil
      @last_updated = Billing::Usage.where(organization_id: current_organization.id,
                                           year: @year, month: @month).first&.updated_at

      respond_to do |format|
        format.json {
          render json: usage_data_as_json(@usage, @usage_decorator.grand_total)
        }
        format.xml {
          render xml: usage_data_as_xml(@usage, @usage_decorator.grand_total)
        }
        format.csv {
          render text: usage_data_as_csv(@usage)
        }
        format.html
      end
    end

  end
end
