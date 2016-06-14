class Support::Api::TicketsController < SupportBaseController#
  include ApplicationHelper
  include TicketsHelper

  newrelic_ignore_apdex only: [:index] if Rails.env.production? || Rails.env.staging?
  skip_before_filter :timeout_session!, only: [:index]
  load_and_authorize_resource :class => "Ticket"

  def index
    @tickets = decorated_tickets

    respond_to do |format|
      format.json {
        render :json => @tickets
      }
      format.html
    end
  end

  def create
    ticket = Ticket.new(create_params.merge(name: Authorization.current_user.name, email: Authorization.current_user.email))
    response = {
      :success => ticket.valid?,
      :message => nil
    }
    if ticket.valid?
      response["message"] = TicketAdapter.create(ticket)
    else
      response["message"] = get_model_errors(ticket)
    end
    respond_to do |format|
      format.json {
        render :json => response
      }
    end
  end

  def update
    result = TicketAdapter.update(update_params)
    respond_to do |format|
      format.json {
        render :json => result
      }
    end
  end

  private

  def create_params
    params.require(:ticket).permit(:title, :description, :department, :priority,
                                   :visitor_names, :nature_of_visit, :date_of_visit, :time_of_visit)
  end

  def update_params
    params.permit(:id, :status, :priority)
  end

end
