class CustomerSignup < ActiveRecord::Base
  after_create -> { update_attributes(uuid: SecureRandom.hex) }

  validates :email, length: {minimum: 5}, allow_blank: false
  validate :email_valid

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

end
