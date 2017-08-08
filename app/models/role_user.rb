class RoleUser < ApplicationRecord
  audited :associated_with => :role

  self.table_name = 'roles_users'

  belongs_to :role
  belongs_to :user

  before_destroy :check_destroyable
  before_save :check_presence, :check_addable
  after_commit :check_openstack_access, :check_ceph_access

  validates :role, :user, presence: true

  private

  def check_presence
    if RoleUser.where(role_id: role.id, user_id: user.id).present?
      errors.add(:base, I18n.t(:user_already_has_role_assigned))
      throw :abort
    else
      return true   
    end
  end

  def check_addable
    if role.power_user? && user.id == Authorization.current_user.id
      errors.add(:base, I18n.t(:cant_add_self_to_role))
      throw :abort
    end
  end

  def check_destroyable
    if role.power_user? && user.id == Authorization.current_user.id
      errors.add(:base, I18n.t(:cant_remove_self_from_role))
      throw :abort
    elsif user.roles.count == 1
      errors.add(:base, I18n.t(:user_needs_at_least_one_role))
      throw :abort
    end
  end

  def check_openstack_access
    CheckOpenStackAccessJob.perform_later(user) unless Rails.env.test?
  end

  def check_ceph_access
    CheckCephAccessJob.perform_later(user)
  end
end