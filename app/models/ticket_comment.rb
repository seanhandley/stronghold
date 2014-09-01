class TicketComment
  include TicketsHelper

  attr_accessor :ticket_reference, :id, :email, :text, :time

  def initialize(params)
    @ticket_reference = params[:ticket_reference]
    @id = params[:id]
    @email = Authorization.current_user.email
    @text = params[:text]
    @time = params[:time]
  end

end