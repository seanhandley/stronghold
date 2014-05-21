class Role < ActiveRecord::Base
  has_and_belongs_to_many :users

  serialize :permissions

  def permissions
    read_attribute(:permissions) || []
  end

  def has_permission?(permission)
    power_user || permissions.include?(permission)
  end
end