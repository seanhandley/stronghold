class Support::Api::TicketsController < SupportBaseController

  skip_authorization_check
  skip_before_action :verify_authenticity_token

  def index
    respond_to do |format|
      format.json {
        render :json => current_user.organization.tickets.all
      }
      format.html
    end
  end

  def create
    reference = current_user.organization.tickets.create(params[:title], params[:description])
    respond_to do |format|
      format.json {
        render :json => reference
      }
    end
  end

end