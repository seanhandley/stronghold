class Support::Api::TicketsController < SupportBaseController

  load_and_authorize_resource :class => "Ticket"
  newrelic_ignore_apdex only: [:index]
  skip_before_filter :timeout_session!, only: [:index]

  def index
    respond_to do |format|
      format.json {
        render :json => current_user.organization.tickets.all
      }
      format.html
    end
  end

  def create
    reference = current_user.organization.tickets.create(create_params)
    respond_to do |format|
      format.json {
        render :json => reference
      }
    end
  end

  def update
    respond_to do |format|
      format.json {
        render :json => current_user.organization.tickets.change_status(update_params)
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