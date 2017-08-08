class ApiCredential < ApplicationRecord
  has_secure_password
  belongs_to :organization_user

  validates :organization_user, :presence => true

  after_create :generate_access_key

  scope :enabled, -> { where(enabled: true) }

  def authenticate_and_authorize(password)
    authenticate(password) && OrganizationUser::Ability.new(organization_user).can?(:read, :api)
  end

  private

  def generate_access_key
    update_column :access_key, SecureRandom.hex unless read_attribute(:access_key)
  end
end
