class CheckOpenStackAccessJob < ActiveJob::Base
  queue_as :default

  def perform(user)
    fog = Fog::Identity.new(OPENSTACK_ARGS)
    if User::Ability.new(user).can?(:read, :cloud)
      fog.update_user(user.uuid, enabled: true)
    else
      fog.update_user(user.uuid, enabled: false)
    end
  end
end