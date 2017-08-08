class CheckOpenStackAccessJob < ApplicationJob
  queue_as :default

  def perform(user)
    if User::Ability.new(user).can?(:read, :cloud)
      fog.update_user(user.uuid, enabled: true)
    else
      fog.update_user(user.uuid, enabled: false)
    end
  end

  def fog
    OpenStackConnection.identity
  end
end