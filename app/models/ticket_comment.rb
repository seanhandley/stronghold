class TicketComment

  include ActiveModel::Validations
  validates :text, length: {minimum: 1}, allow_blank: false

  attr_accessor :ticket_reference, :id, :email, :text, :time, :as_hash, :staff

  def initialize(params)
    @as_hash          = params.dup
    @ticket_reference = params[:ticket_reference]
    @id               = params[:id]
    @email            = params[:email]
    @text             = params[:text]
    @time             = params[:time]
    @staff            = params[:staff]
  end

end
