class Support::TicketsController < SupportBaseController

  skip_authorization_check

  def current_section
    'tickets'
  end

  def index
  end

end