class Support::TicketsController < SupportBaseController

  skip_authorization_check

  def current_section
    'tickets'
  end

  def index
    respond_to do |format|
      format.json {
        render :json => current_user.organization.tickets.all
      }
      format.html
    end
  end

end