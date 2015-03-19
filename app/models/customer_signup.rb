class CustomerSignup < ActiveRecord::Base

  attr_reader :password

  after_create -> { update_attributes(uuid: SecureRandom.hex) }
  after_create -> { Rails.cache.write(cache_id, password, expires_in: 1.hour) }

  validates :first_name, :last_name,
            :password, presence: true
  validates :email, length: {minimum: 5}, allow_blank: false
  validate :email_valid, :password_complexity, :passwords_match

  def initialize(params)
    @password, @confirm_password = params.delete(:password), params.delete(:confirm_password)
    super
  end

  def password
    @password || Rails.cache.fetch(cache_id)
  end

  def expired?
    created_at + 1.hour < Time.zone.now
  end

  private

  def cache_id
    "signup_pass_#{uuid}"
  end

  def email_valid
    errors.add(:email, I18n.t(:is_not_a_valid_address)) unless email =~ /.+@.+\..+/
  end

  def passwords_match
    unless @password && @confirm_password && @password == @confirm_password
      errors.add(:base, "Password doesn't match confirmation")
    end
  end

  def password_complexity
    errors.add(:base, "Password is too short") unless @password && @password.length >= 8
  end
end
