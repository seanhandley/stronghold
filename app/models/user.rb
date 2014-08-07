class User < ActiveRecord::Base
  audited except: [:password_digest, :organization_id]

  has_secure_password
  has_and_belongs_to_many :roles
  belongs_to :organization

  validates :email, :uniqueness => true
  validates :email, :presence => true
  validate :password_complexity

  def has_permission?(permission)
    power_user? || roles.collect(&:permissions).flatten.include?(permission)
  end

  def power_user?
    roles.collect(&:power_user?).include? true
  end

  def name
    name = "#{first_name} #{last_name}".strip
    name.blank? ? email : name
  end

  private

  def password_complexity
    if password.present? && password.length < 8
      errors.add(:base,  'Password is too short')
    end
  end
end