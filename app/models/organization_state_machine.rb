class OrganizationStateMachine
  include Statesman::Machine
  extend OffboardingHelper

  state :fresh, initial: true
  state :active
  state :disabled
  state :dormant
  state :no_payment_methods
  state :frozen
  state :closed

  transition from: :fresh,              to: [:fresh, :active, :frozen, :disabled]
  transition from: :active,             to: [:active, :frozen, :dormant, :disabled, :no_payment_methods, :closed]
  transition from: :frozen,             to: [:frozen, :active, :closed]
  transition from: :disabled,           to: [:disabled, :active, :frozen, :closed]
  transition from: :dormant,            to: [:dormant, :active]
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
      Mailer.review_mode_alert(organization).deliver_later
    end
  end

  before_transition(from: :frozen, to: :active) do |organization, transition|
    organization.unfreeze!
    Mailer.review_mode_successful(organization).deliver_later
  end

  before_transition(from: :dormant, to: :active) do |organization, transition|
    organization.projects.each do |project|
      ProjectResources.new(project.uuid).reattach_router_gateways
    end
  end

  before_transition(from: :active, to: :dormant) do |organization, transition|
    organization.projects.each do |project|
      ProjectResources.new(project.uuid).clear_router_gateways
    end
  end

  [:fresh, :active, :no_payment_methods].each do |before_state|
    before_transition(from: before_state, to: :disabled) do |organization, transition|
      organization.disable_users_and_projects!
    end
  end

  [:frozen, :active].each do |before_state|
    before_transition(from: before_state, to: :closed) do |organization, transition|
      auth_token         = transition.metadata['auth_token']
      user_email         = transition.metadata['user_email']
      creds = {}
      if user_email
        Notifications.notify(:account_alert, "#{organization.name} (REF: #{organization.reference}) has requested account termination.")
        creds = {:openstack_username => user_email,
                 :openstack_api_key  => nil,
                 :openstack_auth_token => auth_token,
                 :openstack_project_name   => organization.primary_project.reference,
                 :openstack_domain_id  => 'default',
                 :openstack_identity_prefix => 'v3',
                 :openstack_endpoint_path_matches => //}
      end
      organization.projects.each do |project|
        offboard(project, creds)
        begin
          Ceph::User.update('uid' => project.uuid, 'suspended' => true)
        rescue Net::HTTPError => e
          Honeybadger.notify(e)
        end
      end
      organization.disable_users_and_projects!
      organization.update_column(:disabled, true)
      Mailer.goodbye(organization.admin_users).deliver_later
    end
  end

  before_transition(from: :disabled, to: :active) do |organization, transition|
    organization.enable_users_and_projects!
  end

end
