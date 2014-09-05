class TicketDecorator < ApplicationDecorator

  def user(hash)
    User.find_by email: hash["email"]
  end

  def staff?(hash)
    user(hash).staff?
  end

  def display_name(hash)
    if user(hash).present?
      user(hash).name
    else
      email_start = hash["email"].split("@")[0]
      email_start.gsub(".", " ").titleize
    end
  end

  def thing_to_hash(thing)
    hash = {}
    thing.instance_variables.each {|var| hash[var.to_s.delete("@")] = thing.instance_variable_get(var) }
    hash
  end

  def decorate
    ticket = thing_to_hash model
    ticket["display_name"] = display_name ticket
    ticket["staff"] = true if staff?(ticket)
    ticket["comments"] = ticket.comments.collect do |comment|
      comment = thing_to_hash comment
      comment["display_name"] = display_name comment
      comment["staff"] = true if staff?(comment)
      comment
    end
    ticket
  end

end