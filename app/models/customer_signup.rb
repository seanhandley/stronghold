class CustomerSignup < ApplicationRecord
  include ActionView::Helpers::UrlHelper
  include StripeHelper

  attr_reader :error_message

  after_create -> { update_column(:uuid, SecureRandom.urlsafe_base64) }
  after_commit :send_email, on: :create, unless: -> { retro_migrated? }

  validate :email_valid, unless: -> { retro_migrated? }

  scope :not_reminded, -> { where(reminder_sent: false)}

  def ready?
    return false unless organization.fresh?
    @error_message = nil
    unless address_check_passed?
      @error_message = 'The address does not match the card. Try activating by phone?'
      return false
    end
    unless cvc_check_passed?
      @error_message = 'Please use a card that has a valid CVC number'
      return false
    end
    stripe_customer_id.present?
  end

  def organization_name
    return read_attribute(:organization_name) unless read_attribute(:organization_name).blank?
    email
  end

  def organization
    Organization.find_by_customer_signup_id(id)
  end

  def country
    @country ||= GeoIp.geolocation(ip_address) rescue OpenStruct.new(country_code: 'GB', country_name: "United Kingdom")
  end

  def other_signups_from_device
    return 0 unless device_id
    CustomerSignup.where(device_id: device_id).count - 1
  end

  def stripe_customer
    return nil unless stripe_customer_id.present?
    rescue_stripe_errors(lambda {|msg| msg.include?('No such customer') ? nil : raise(msg) }) do
      @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_id)
    end
  end

  def prepaid?
    return false unless stripe_customer
    return true if stripe_customer.sources.data.first.funding == "prepaid"
    false
  end

  def no_cvc?
    return false unless stripe_customer
    return true if stripe_customer.sources.data.first.cvc_check == "unavailable"
    false
  end

  private

  def email_valid
    errors.add(:email, I18n.t(:is_not_a_valid_address)) unless email =~ /.+@.+\..+/
    errors.add(:email, I18n.t(:is_not_a_valid_address)) unless email.length >= 5
    errors.add(:email, 'is already in use') if User.find_by_email(email.downcase) && email_changed?
    errors.add(:email, "already used to sign up! If you didn't receive a sign up email, please contact support@datacentred.co.uk") if CustomerSignup.find_by_email(email.downcase) && email_changed?
    throw(:abort) if errors.any?
  end

  def address_check_passed?
    return false unless stripe_customer
    return false unless ['pass','unavailable', 'unchecked'].include?(stripe_customer.sources.data.first.address_line1_check)
    return false unless ['pass','unavailable', 'unchecked'].include?(stripe_customer.sources.data.first.address_zip_check)
    true
  end

  def cvc_check_passed?
    return false unless stripe_customer
    return false unless ['pass','unavailable', 'unchecked'].include?(stripe_customer.sources.data.first.cvc_check)
    true
  end

  def send_email
    CustomerSignupJob.perform_later(id)
  end

end
