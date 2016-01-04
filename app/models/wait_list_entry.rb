class WaitListEntry < ApplicationRecord

  validates :email, length: {minimum: 5}, allow_blank: false
  validate :email_valid

  scope :awaiting_email, -> { where('emailed_at IS NULL') }

  private

  def email_valid
    errors.add(:email, I18n.t(:is_not_a_valid_address)) unless email =~ /.+@.+\..+/
    errors.add(:email, 'is already signed up') if User.find_by_email(email) && email_changed?
    throw :abort if errors.any?
  end

end


