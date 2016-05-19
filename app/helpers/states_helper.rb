module StatesHelper
  def options_for_states(organization)
    states = Organization::OrganizationStates.constants.map do |k|
      [k.to_s.underscore.humanize.titleize, Organization::OrganizationStates.const_get(k)]
    end.reject do |e|
      Organization::OrganizationStates::Fresh == e[1]
    end
    options_for_select(states, selected: organization.state)
  end
end
