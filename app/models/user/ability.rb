class User::Ability
  include CanCan::Ability

  def initialize(user)
    alias_action :new, :create, :edit, :update, :destroy, :to => :modify

    can :read, Instance if user.has_permission?('instances.read')
    can :read, Role if user.has_permission?('roles.read')
    can [:read, :modify], Role if user.has_permission?('roles.read')

    ## Power User can do everything
    can [:read, :modify], :all if user.power_user?

  end
end
