class Signup < ActiveRecord::Base
  after_create :generate_token

  validates :email, length: {minimum: 3}, allow_blank: false

  def complete!
    update_attributes(completed_at: Time.now)
  end

  def complete?
    !!completed_at
  end

  private

  def generate_token
    return if token
    update_column(:token, SecureRandom.hex(16))
  end
end