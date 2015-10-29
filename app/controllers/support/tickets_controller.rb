class Support::TicketsController < SupportBaseController

  load_and_authorize_resource :class_name => 'Ticket'
  before_filter :get_departments_and_priorities

  def ensure_trailing_slash
    redirect_to url_for(params = :trailing_slash => true), :status => 301 unless trailing_slash?
  end

  def trailing_slash?
    request.original_url.match(/[^\?]+/).to_s.last == '/'
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

  private

  def get_departments_and_priorities
    @departments = TicketAdapter.departments
    @priorities  = TicketAdapter.priorities
    @priorities.delete('Emergency') unless current_organization.known_to_payment_gateway?
    unless current_organization.colo? && current_user.has_permission?('access_requests.modify')
      @departments -= ['Access Requests']
    end
  rescue Sirportly::Error => e
    notify_honeybadger(e)
    @departments = []
    @priorities = []
  end

end
