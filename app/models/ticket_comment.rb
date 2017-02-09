class TicketComment

  include ActiveModel::Validations
  validates :text, length: {minimum: 1}, allow_blank: false

  attr_accessor :ticket_reference, :id, :email, :text,
                :time, :as_hash, :staff, :unread

  def initialize(params)
    @ticket_reference = params[:ticket_reference]
    @id               = params[:id]
    @email            = params[:email]
    @text             = params[:text]
    @time             = params[:time]
    @staff            = params[:staff]
    @unread           = unread_class
    @as_hash          = params.dup.merge(unread: unread_class)
  end

  private

  def unread_class
    params = {
      update_id: id,
      ticket_id: ticket_reference,
      user_id: Authorization&.current_user&.id
    }
    if ticket = UnreadTicket.find_by(params)
      'unread-comment'
    else
      ''
    end
  end

end
