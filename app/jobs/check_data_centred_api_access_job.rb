class CheckDataCentredApiAccessJob < ApplicationJob
  queue_as :default

  def perform(organization, user, state=nil)
    credential = ApiCredential.find_by(user: user, organization: organization)
    return unless credential

    case state
    when nil
      if organization.frozen?
        credential.update_attributes enabled: false
      else
        credential.update_attributes enabled: User::Ability.new(user).can?(:read, :api)
      end
    else
      credential.update_attributes enabled: state
    end
  end
end
