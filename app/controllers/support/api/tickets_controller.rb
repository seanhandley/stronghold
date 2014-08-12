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
    reference = current_user.organization.tickets.create(params[:title], params[:description], current_user.email)
    respond_to do |format|
      format.json {
        render :json => reference
      }
    end
  end

  def add_comment
    reference = params[:ticket_id]
    response = current_user.organization.tickets.add_comment(reference, params[:text])
    respond_to do |format|
      format.json {
        render :json => response
      }
    end
  end

end
