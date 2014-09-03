class Support::Api::TicketsController < SupportBaseController#

  include ApplicationHelper

  newrelic_ignore_apdex only: [:index]
  skip_before_filter :timeout_session!, only: [:index]
  load_and_authorize_resource :class => "Ticket"

  def index
    respond_to do |format|
      format.json {
        render :json => current_user.organization.tickets.all
      }
      format.html
    end
  end

  def create
    ticket = Ticket.new(create_params)
    response = {
      success => ticket.valid?,
      message => ""
    }
    if ticket.valid?
      response.message = current_user.organization.tickets.create(ticket)
    else
      response.message = get_model_errors(ticket)
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
        render :json => current_user.organization.tickets.change_status(
          update_params[:id],
          update_params[:status]
        )
      }
    end
  end

  private

  def create_params
    params.require(:ticket).permit(:title, :description)
  end

  def update_params
    params.permit(:id, :status)
  end

end