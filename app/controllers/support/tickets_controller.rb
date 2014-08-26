class Support::TicketsController < SupportBaseController

  skip_authorization_check

  def current_section
    'tickets'
  end

  def show
    @reference = params[:id]
    render :index
  end

  def index
  end

end