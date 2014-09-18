class TicketDecorator < ApplicationDecorator

  def decorate
    ticket = model.as_hash
    comments = ticket[:comments].compact.collect do |c|
      c
    end
    ticket.merge(comments: comments)
  end

end