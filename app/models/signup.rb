class Signup < ActiveRecord::Base
  after_create :generate_token

  validates :email, length: {minimum: 3}, allow_blank: false

  private

  def generate_token
    return if token
    write_attribute(:token, SecureRandom.hex(16))
  end
end