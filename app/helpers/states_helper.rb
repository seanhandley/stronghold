module StatesHelper
  include ActionView::Helpers::FormOptionsHelper
  def options_for_states(organization)
    states = organization.allowed_transitions
    states = states.map{|state| [state.underscore.humanize.titleize, state]}.sort{|x,y| x[0] <=> y[0]}
    options_for_select(states)
  end
end
