class User < ActiveRecord::Base
  has_secure_password
  has_and_belongs_to_many :roles

  def has_permission?(permission)
    power_user? || roles.collect(&:permissions).flatten.include?(permission)
  end

  def power_user?
    roles.collect(&:power_user?).include? true
  end

  def name
    "#{first_name} #{last_name}".strip
  end
end