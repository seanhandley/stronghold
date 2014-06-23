class Invite < ActiveRecord::Base
  after_create :generate_token

  validates :email, length: {minimum: 5}, allow_blank: false
  validate :has_roles?
  validate :email_looks_valid?

  belongs_to :organization
  has_and_belongs_to_many :roles

  def can_register?
    if active? && !complete?
      true
    else
      false
    end
  end

  def complete!
    update_attributes(completed_at: Time.now)
  end

  def expires_at
    persisted? ? created_at + 72.hours : Time.now + 72.hours
  end

  private

  def complete?
    !!completed_at
  end

  def active?
    !complete? && (expires_at > Time.now)
  end

  def power_invite?
    organization.blank?
  end

  def generate_token
    return if token
    update_column(:token, SecureRandom.hex(16))
  end

  def has_roles?
    errors.add(:base, "Please give this user at least one role") unless power_invite? || roles.present?
  end

  def email_looks_valid?
    errors.add(:email, "is not a valid address") unless email =~ /.+@.+\..+/
  end
end