class Invite < ActiveRecord::Base
  after_create :generate_token

  validates :email, length: {minimum: 3}, allow_blank: false

  belongs_to :organization
  has_and_belongs_to_many :roles

  def is_valid?
    if active? && !complete?
      true
    else
      raise ArgumentError, 'this signup token is invalid'
    end
  end

  def complete!
    update_attributes(completed_at: Time.now)
  end

  def expires_at
    created_at ? created_at + 72.hours : Time.now + 72.hours
  end

  private

  def complete?
    !!completed_at
  end

  def active?
    !complete? && (expires_at > Time.now)
  end

  def generate_token
    return if token
    update_column(:token, SecureRandom.hex(16))
  end
end