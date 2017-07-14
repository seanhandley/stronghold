class CheckDataCentredApiAccessJob < ApplicationJob
  queue_as :default

  def perform(user, organization)
    credential = ApiCredential.find_by(user: user, organization: organization)
    return unless credential

    credential.update_attributes enabled: User::Ability.new(user).can?(:read, :api)
  end
end