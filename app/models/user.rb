class User < ActiveRecord::Base
  has_secure_password
  has_and_belongs_to_many :roles
  belongs_to :organization

  validates :email, :uniqueness => true
  validates :email, :presence => true

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
end