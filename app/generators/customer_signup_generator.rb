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
    offset = GeoIp.geolocation(@customer_signup.ip_address, :timezone => true)[:timezone].split(':')[0]
    @organization = Organization.create! name: @customer_signup.organization_name,
                                         customer_signup: @customer_signup,
                                         state: OrganizationStates::Fresh,
                                         timezone: ActiveSupport::TimeZone[offset].name rescue 'London'
    @organization.products << Product.find_by_name('Compute')
    @organization.products << Product.find_by_name('Storage')
    @organization.save!

    @invite = Invite.create! email: @customer_signup.email, power_invite: true,
                             organization: @organization, customer_signup: @customer_signup
    Hipchat.notify('Self Service', 'Accounts', "New user signed up: #{@customer_signup.email} becoming organization #{@organization.id}", color: 'green')
  end
end