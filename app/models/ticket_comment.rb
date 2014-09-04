class TicketComment

  include ApplicationHelper
  include ActiveModel::Validations
  validates :text, length: {minimum: 1}, allow_blank: false

  attr_accessor :ticket_reference, :id, :email, :text, :time

  def initialize(params)
    @ticket_reference = params[:ticket_reference]
    @id = params[:id]
    set_email(params[:email])
    @text = params[:text]
    @time = params[:time]
  end

  def set_email(email)
    @email = email
    @display_name = email_to_display_name(email)
  end

end