class TicketDecorator < ApplicationDecorator

  def user(hash)
    puts hash["email"].inspect
    User.find_by email: hash["email"]
  end

  def staff?(hash)
    u = user(hash)
    u.present? ? u.staff? : false
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
    ticket["staff"] = staff?(ticket)
    ticket["comments"] = ticket["comments"].collect do |comment|
      comment = thing_to_hash comment
      comment["display_name"] = display_name comment
      comment["staff"] = staff?(comment)
      comment
    end
    ticket
  end

end