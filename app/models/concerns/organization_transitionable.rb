module OrganizationTransitionable
  include Statesman::Adapters::ActiveRecordQueries

  def self.included(base)
    base.class_eval do
      has_many :transitions, class_name: "OrganizationTransition", autosave: false
    end
  end

  def state_machine
    @state_machine ||= OrganizationStateMachine.new(self, transition_class: OrganizationTransition,
                                                          association_name: :transitions)
  end

  def self.transition_class
    OrganizationTransition
  end
  private_class_method :transition_class

  def self.initial_state
    :fresh
  end
  private_class_method :initial_state

  delegate :can_transition_to?, :transition_to!, :transition_to, :current_state, :allowed_transitions,
           to: :state_machine
end
