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
    begin
      if current_organization.colo?
        authorize!(:raise_for_self,   ticket) if access_request_self_params.any?   {|p| create_params[p]}
        authorize!(:raise_for_others, ticket) if access_request_others_params.any? {|p| create_params[p]}
      end
      if ticket.valid?
        response["message"] = TicketAdapter.create(ticket)
      else
        response["message"] = get_model_errors(ticket)
      end
    rescue CanCan::Error => e
      response[:success] = false
      response[:message] = [{"field" => "Error:", "message" => e.message}]
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
    params.require(:ticket).permit(*ticket_params)
  end

  def ticket_params
    ([:title, :description, :department, :priority] + access_request_params).uniq
  end

  def access_request_params
    access_request_others_params + access_request_self_params
  end

  def access_request_self_params
    [:nature_of_visit, :date_of_visit, :time_of_visit]
  end


  def access_request_others_params
    [:visitor_names]
  end

  def update_params
    params.permit(:id, :status, :priority)
  end

end
