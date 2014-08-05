class Role < ActiveRecord::Base
  audited :associated_with => :organization, except: [:organization_id, :power_user]
  has_associated_audits

  has_and_belongs_to_many :users
  belongs_to :organization
  before_destroy :check_users, :check_power

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
      errors.add(:base, 'You cannot remove a role which has users assigned to it')
      false
    end
  end

  def check_power
    if power_user?
      errors.add(:base, 'This is a power user group and may not be removed')
      false
    end  
  end
end