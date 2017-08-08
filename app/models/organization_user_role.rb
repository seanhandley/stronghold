class OrganizationUserRole < ApplicationRecord
  audited :associated_with => :role

  self.table_name = 'organizations_users_roles'

  belongs_to :role
  belongs_to :organization_user

  before_destroy :check_destroyable
  before_save :check_organization, :check_presence, :check_addable
  after_commit :check_openstack_access, :check_ceph_access, on: :create

  validates :role, :organization_user, presence: true

  private

  def check_presence
    if OrganizationUserRole.find_by(role: role, organization_user: organization_user)
      errors.add(:base, I18n.t(:user_already_has_role_assigned))
      throw :abort
    else
      return true
    end
  end

  def check_addable
    if role.power_user? && organization_user == Authorization.current_organization_user
      errors.add(:base, I18n.t(:cant_add_self_to_role))
      throw :abort
    end
  end

  def check_destroyable
    if role.power_user? && organization_user == Authorization.current_organization_user
      errors.add(:base, I18n.t(:cant_remove_self_from_role))
      throw :abort
    elsif organization_user.user.roles.count == 1
      errors.add(:base, I18n.t(:user_needs_at_least_one_role))
      throw :abort
    end
  end

  def check_organization
    if role.organization_id != organization_user.organization_id
      errors.add(:base, "Role and user must belong to the same organization")
      throw :abort
    end
  end

  def check_openstack_access
    CheckOpenStackAccessJob.perform_later(organization_user) unless Rails.env.test?
  end

  def check_ceph_access
    CheckCephAccessJob.perform_later(organization_user)
  end
end
