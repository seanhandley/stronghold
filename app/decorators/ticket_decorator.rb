class TicketDecorator < ApplicationDecorator

  def staff?
    model.user ? model.user.staff? : false
  end

  def display_name
    if model.user.present?
      model.user.name
    else
      email_start = model.user.email.split("@")[0]
      email_start.gsub(".", " ").titleize
    end
  end

  def decorate
    ticket = model.as_hash.merge(display_name: display_name, staff: staff?)
    comments = [ticket[:comments]].flatten.compact.collect do |c|
      c.merge(display_name: display_name, staff: staff?)
    end
    ticket.merge(comments: comments)
  end

end