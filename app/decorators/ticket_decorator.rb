class TicketDecorator < ApplicationDecorator
  def user
    {
      :name => (not model.nil? ? model.user.name : model.user.email)
    }
  end
end