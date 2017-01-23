class ApiCredential < ApplicationRecord
  has_secure_password
  belongs_to :user

  after_save :generate_access_key, on: :create

  private

  def generate_access_key
    update_column :access_key, SecureRandom.base64
  end
end
