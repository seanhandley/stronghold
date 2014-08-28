class Support::TicketsController < SupportBaseController

  load_and_authorize_resource :class_name => 'Ticket'

  def ensure_trailing_slash
    redirect_to url_for(params = :trailing_slash => true), :status => 301 unless trailing_slash?
  end

  def trailing_slash?
    request.env['REQUEST_URI'].match(/[^\?]+/).to_s.last == '/'
  end

  before_filter :ensure_trailing_slash, :only => :index

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