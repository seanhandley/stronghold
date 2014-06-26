class RoleUser < ActiveRecord::Base
  self.table_name = 'roles_users'

  attr_accessor :current_user

  belongs_to :role
  belongs_to :user

  before_destroy :check_destroyable

  private

  def check_destroyable
    if role.power_user? && user.id == current_user.id
      errors.add(:base, "You can't remove yourself from the #{role.name} role. Please request another user with the right privileges removes you.")
      return false
    elsif user.roles.count == 1
      errors.add(:base, "A user needs at least one role. Please assign them another before removing them from the #{role.name} role.")
      return false
    end
    return true
  end
end