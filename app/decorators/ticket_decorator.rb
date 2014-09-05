class TicketDecorator < ApplicationDecorator

  def get_display_name(hash)
    user = User.find_by email: hash["email"]
    if (user.present?)
      user.name
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
    hash = thing_to_hash(model)
    hash["display_name"] = get_display_name(hash)
    hash["comments"] = model.comments.collect do |comment|
      comment = thing_to_hash(comment)
      comment["display_name"] = get_display_name(comment)
      comment
    end
    hash
  end

end