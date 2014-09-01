class Support::Api::TicketsController < SupportBaseController

  newrelic_ignore_apdex only: [:index]
  skip_before_filter :timeout_session!, only: [:index]
  skip_authorization_check

  def index
    respond_to do |format|
      format.json {
        render :json => current_user.organization.tickets.all
      }
      format.html
    end
  end

  def create
    ticket = Ticket.new(
      create_params[:title],
      create_params[:description]
    )
    # Validation goes here (looking good)
    reference = current_user.organization.tickets.create(ticket)
    respond_to do |format|
      format.json {
        # render :json => reference
        render :json => reference
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
    params.permit(:title, :description)
  end

  def update_params
    params.permit(:id, :status)
  end

end