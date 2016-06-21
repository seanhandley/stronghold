class OrganizationStateMachine
  include Statesman::Machine
  include OffboardingHelper

  state :fresh, initial: true
  state :active
  state :disabled
  state :no_payment_methods
  state :frozen
  state :closed

  transition from: :fresh,              to: [:fresh, :active, :frozen, :disabled]
  transition from: :active,             to: [:active, :frozen, :disabled, :no_payment_methods, :closed]
  transition from: :frozen,             to: [:frozen, :active, :closed]
  transition from: :disabled,           to: [:disabled, :active, :frozen, :closed]
  transition from: :no_payment_methods, to: [:no_payment_methods, :frozen, :disabled, :active]
  transition from: :closed,             to: [:closed, :active]

  before_transition(from: :fresh, to: :active) do |organization, transition|
    organization.enable_users_and_projects!
    args = transition.metadata['signup_args']
    if args
      organization.update_attributes(started_paying_at: Time.now.utc)
      organization.update_attributes(stripe_customer_id: args['stripe_customer_id'])
      ActivateCloudResourcesJob.perform_later(organization, args['voucher'])
    end
  end

  [:fresh, :active, :disabled, :no_payment_methods].each do |before_state|
    before_transition(from: before_state, to: :frozen) do |organization, transition|
      organization.hard_freeze!
      Mailer.review_mode_alert(organization)
    end
  end

  before_transition(from: :frozen, to: :active) do |organization, transition|
    organization.unfreeze!
    Mailer.review_mode_successful(organization).deliver_later
  end

  [:fresh, :active, :no_payment_methods].each do |before_state|
    before_transition(from: before_state, to: :disabled) do |organization, transition|
      organization.disable_users_and_projects!
    end
  end

  [:frozen, :active].each do |before_state|
    before_transition(from: before_state, to: :closed) do |organization, transition|
      auth_token           = transition.metadata['auth_token']
      current_user         = transition.metadata['current_user']
      current_organization = current_user.organization
      Notifications.notify(:account_alert, "#{current_organization.name} (REF: #{current_organization.reference}) has requested account termination.")
      creds = {:openstack_username => current_user.email,
               :openstack_api_key  => nil,
               :openstack_auth_token => auth_token,
               :openstack_project_name   => current_organization.primary_project.reference,
               :openstack_domain_id  => 'default',
               :openstack_identity_prefix => 'v3',
               :openstack_endpoint_path_matches => //}
      current_organization.projects.each do |project|
        offboard(project, creds)
        begin
          Ceph::User.update('uid' => project.uuid, 'suspended' => true)
        rescue Net::HTTPError => e
          Honeybadger.notify(e)
        end
      end
      Mailer.goodbye(current_organization.admin_users).deliver_later
    end
  end

  before_transition(from: :disabled, to: :active) do |organization, transition|
    organization.enable_users_and_projects!
  end

end
