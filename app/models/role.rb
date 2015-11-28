class Role < ActiveRecord::Base
  audited :associated_with => :organization, except: [:organization_id, :power_user]
  has_associated_audits

  has_and_belongs_to_many :users
  belongs_to :organization
  before_destroy :check_power, :check_users
  after_commit :check_openstack_access, :check_ceph_access

  serialize :permissions

  validates :name, length: {minimum: 1}, allow_blank: false

  def permissions
    read_attribute(:permissions) || []
  end

  def has_permission?(permission)
    power_user || permissions.include?(permission)
  end

  private

  def check_users
    if users.present?
      errors.add(:base, I18n.t(:role_has_users_assigned))
      false
    end
  end

  def check_power
    if power_user? && users.any?
      errors.add(:base, I18n.t(:cannot_remove_power_user_group))
      false
    end  
  end

  def check_openstack_access
    users.each {|user| CheckOpenStackAccessJob.perform_later(user)}
  end

  def check_ceph_access
    users.each {|user| CheckCephAccessJob.perform_later(user)}
  end
end