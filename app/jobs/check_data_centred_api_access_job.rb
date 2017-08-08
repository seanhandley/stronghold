class CheckDataCentredApiAccessJob < ApplicationJob
  queue_as :default

  def perform(organization_user, state=nil)
    credential = organization_user.api_credential
    return unless credential

    case state
    when nil
      if organization_user.organization.frozen?
        credential.update_attributes enabled: false
      else
        credential.update_attributes enabled: OrganizationUser::Ability.new(organization_user).can?(:read, :api)
      end
    else
      credential.update_attributes enabled: state
    end
  end
end
