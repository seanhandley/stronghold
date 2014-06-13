class Support::Api::TicketsController < SupportBaseController

  skip_authorization_check

  def index
    respond_to do |format|
      format.json {
        render :json => current_user.organization.tickets.all
      }
      format.html
    end
  end

  def show
    respond_to do |format|
      format.json {
        render :json => current_user.organization.tickets.some_ticket(params[:id]).to_json
      }
    end
  end

end