class CustomerSignupGenerator

  attr_reader :customer_signup

  def initialize(customer_signup_id)
    @customer_signup = CustomerSignup.find(customer_signup_id)
  end

  def generate!
    error = nil
    ActiveRecord::Base.transaction do
      begin
        create_customer
      rescue StandardError => e
        error = e
        raise ActiveRecord::Rollback
      end
    end

    raise error if error
    return true
  end

  private

  def create_customer
    @organization = Organization.create! name: @customer_signup.organization_name
    @organization.products << Product.find_by_name('Compute')
    @organization.products << Product.find_by_name('Storage')
    @organization.save!

    @invite = Invite.create! email: @customer_signup.email, power_invite: true,
                             organization: @organization, customer_signup: @customer_signup
    Mailer.signup(@invite.id).deliver_later
    Hipchat.notify('Self Service', 'Signups', "New user signed up: #{@customer_signup.email} becoming organization #{@organization.id}")
  end
end