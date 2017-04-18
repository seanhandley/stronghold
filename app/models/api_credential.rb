class ApiCredential < ApplicationRecord
  has_secure_password
  belongs_to :user
  belongs_to :organization

  validates :user, :organization, :presence => true

  after_create :generate_access_key

  def authenticate_and_authorize(password)
    authenticate(password) && User::Ability.new(user).can?(:read, :api)
  end

  private

  def generate_access_key
    update_column :access_key, SecureRandom.hex unless read_attribute(:access_key)
  end
end
