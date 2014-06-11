class Support::TicketsController < SupportBaseController

  skip_authorization_check

  def current_section
    'tickets'
  end

  def index
    @organization = current_user.organization
    #@tickets = @organization.tickets.closed
  end

end