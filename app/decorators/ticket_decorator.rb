class TicketDecorator < ApplicationDecorator

  def decorate
    user = User.find_by email: model.email
    hash = {}
    model.instance_variables.each {|var| hash[var.to_s.delete("@")] = model.instance_variable_get(var) }
    if (user.present?)
      hash["display_name"] = user.name
    else
      hash["display_name"] = model.email
    end
    hash
  end

end