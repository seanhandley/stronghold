class CheckDataCentredApiAccessJob < ApplicationJob
  queue_as :default

  def perform(organization, user, state=nil)
    credential = ApiCredential.find_by(user: user, organization: organization)
    return unless credential

    credential.update_attributes enabled: (state.nil? ? User::Ability.new(user).can?(:read, :api) : state)
  end
end