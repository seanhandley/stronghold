class Support::Api::TicketsController < SupportBaseController#

  include ApplicationHelper

  newrelic_ignore_apdex only: [:index]
  skip_before_filter :timeout_session!, only: [:index]
  load_and_authorize_resource :class => "Ticket"

  def index
    @tickets = TicketAdapter.all(params[:page]).collect do |t|
      TicketDecorator.new(t).decorate
    end
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
    respond_to do |format|
      format.json {
        render :json => TicketAdapter.change_status(
          update_params[:id],
          update_params[:status]
        )
      }
    end
  end

  private

  def create_params
    params.require(:ticket).permit(:title, :description, :department)
  end

  def update_params
    params.permit(:id, :status)
  end

end