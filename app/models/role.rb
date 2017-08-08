class Role < ApplicationRecord
  audited :associated_with => :organization, except: [:organization_id, :power_user]
  has_associated_audits

  has_and_belongs_to_many :organization_users, -> { distinct }
  has_many :users, through: :organization_users
  belongs_to :organization
  before_destroy :check_power, :check_users
  after_commit :check_openstack_access, :check_ceph_access, :check_datacentred_api_access
  after_save :generate_uuid, :on => :create

  serialize :permissions

  validates :name, length: {minimum: 1}, allow_blank: false
  validate :permissions_are_valid

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
      throw :abort
    end
  end

  def check_power
    if power_user? && users.any?
      errors.add(:base, I18n.t(:cannot_remove_power_user_group))
      throw :abort
    end
  end

  def check_openstack_access
    organization_users.each {|ou| CheckOpenStackAccessJob.perform_later(ou)}
  end

  def check_ceph_access
    return unless Rails.env.production?
    organization_users.each {|ou| CheckCephAccessJob.perform_later(ou)}
  end

  def check_datacentred_api_access
    organization_users.each {|ou| CheckDataCentredApiAccessJob.perform_later(ou)}
  end

  def permissions_are_valid
    return true unless permissions.any?
    permissions.each do |permission|
      unless Permissions.user.keys.include?(permission)
        errors.add(:permissions, "must be one of: #{Permissions.user.keys.sort.map{|k| '\'' + k +'\'' }.join(', ')}. '#{permission}' is not allowed") 
        throw :abort
      end
    end
  end

  def generate_uuid
    update_column(:uuid, SecureRandom.uuid)
  end
end