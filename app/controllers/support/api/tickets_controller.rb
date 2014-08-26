class Support::Api::TicketsController < SupportBaseController

  skip_authorization_check
  skip_before_action :verify_authenticity_token
  newrelic_ignore_apdex only: [:index]

  def index
    respond_to do |format|
      format.json {
        render :json => current_user.organization.tickets.all
      }
      format.html
    end
  end

  def create
    reference = current_user.organization.tickets.create(params[:title], params[:description], current_user.email)
    respond_to do |format|
      format.json {
        render :json => reference
      }
    end
  end

  def update
    issue_reference = params[:id]
    status = params[:status]
    respond_to do |format|
      format.json {
        render :json => current_user.organization.tickets.change_status(issue_reference, status)
      }
    end
  end

end