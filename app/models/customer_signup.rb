class CustomerSignup < ActiveRecord::Base
  after_create -> { update_attributes(uuid: SecureRandom.hex) }

  validates :email, length: {minimum: 5}, allow_blank: false
  validate :email_valid

  def ready?
    stripe_customer_id.present? && address_check_passed?
  end

  def organization_name
    return read_column(:organization_name) unless read_column(:organization_name).blank?
    email
  end

  private

  def cache_id
    "signup_pass_#{uuid}"
  end

  def email_valid
    errors.add(:email, I18n.t(:is_not_a_valid_address)) unless email =~ /.+@.+\..+/
    errors.add(:email, 'is already in use') if User.find_by_email(email)
  end

  def address_check_passed?
    return false unless stripe_customer
    return false unless stripe_customer.sources.data.first.address_line1_check == 'pass'
    return false unless stripe_customer.sources.data.first.address_zip_check   == 'pass'
    true
  end

  def stripe_customer
    Stripe::Customer.retrieve(stripe_customer_id)
  rescue Stripe::InvalidRequestError => e
    if e.message.include? 'No such customer'
      return nil
    else
      raise
    end
  end

end


