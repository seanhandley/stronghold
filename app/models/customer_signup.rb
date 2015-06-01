class CustomerSignup < ActiveRecord::Base
  after_create -> { update_attributes(uuid: SecureRandom.hex) }
  after_commit :send_email, on: :create

  validate :email_valid

  scope :not_reminded, -> { where(reminder_sent: false)}

  def ready?
    stripe_customer_id.present? && address_check_passed?
  end

  def organization_name
    return read_attribute(:organization_name) unless read_attribute(:organization_name).blank?
    email
  end

  def organization
    Organization.find_by_customer_signup_id(id)
  end

  private

  def email_valid
    return errors.add(:email, I18n.t(:is_not_a_valid_address)) unless email =~ /.+@.+\..+/
    return errors.add(:email, I18n.t(:is_not_a_valid_address)) unless email.length >= 5
    return errors.add(:email, 'is already in use') if User.find_by_email(email.downcase) && email_changed?
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

  def send_email
    CustomerSignupJob.perform_later(id)
    Mailer.notify_staff_of_signup(self).deliver_later
  end

end


