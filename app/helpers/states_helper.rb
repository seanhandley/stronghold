module StatesHelper
  include ActionView::Helpers::FormOptionsHelper
  def options_for_states(organization)
    states = organization.allowed_transitions
    states = states.map{|state| [state.underscore.humanize.titleize, state]}.sort{|x,y| x[0] <=> y[0]}
    options_for_select(states)
  end

  def colours_for_states(organization)
    if ["active", "fresh"].include?(organization.state)
      state_colour = "label label-success"
    elsif ["frozen", "dormant", "no_payment_methods"].include?(organization.state)
      state_colour = "label label-warning"
    else
      state_colour = "label label-danger"
    end
    state_colour
  end

  def names_for_satates(organization)
    if ["active", "fresh"].include?(organization.state)
      state_name = "Active"
    elsif ["frozen", "dormant", "no_payment_methods"].include?(organization.state)
      state_name = "In review"
    else
      state_name = "Disabled"
    end
    state_name
  end

  def states_info(organization)

  end
end
