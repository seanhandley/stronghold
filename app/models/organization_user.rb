class OrganizationUser < ActiveRecord::Base

  self.table_name = 'organizations_users'
  after_initialize :check_if_temporary_membership_expired
  after_save :set_primary, on: :create
  after_commit :generate_ec2_credentials, on: :create
  after_commit :check_openstack_access, :check_ceph_access, :check_datacentred_api_access, on: :create

  before_destroy :check_if_should_destroy_user, :check_if_primary_and_current_user
  before_destroy :remove_ceph_keys
  before_destroy :remove_from_openstack_and_ceph

  DEFAULT_MEMBERSHIP_DURATION_IN_HOURS = 4

  belongs_to :organization
  belongs_to :user

  has_many :roles, through: :organization_user_roles

  has_many :organization_user_roles, dependent: :destroy
  has_many :api_credentials,         dependent: :destroy
  has_many :user_project_roles,      dependent: :destroy
  has_many :unread_tickets,          dependent: :destroy

  def temporary?
    !!duration
  end

  def expires_at
    updated_at + duration.hours unless duration.nil?
  end

  def expired?
    expires_at <= Time.now
  end

  def reset!
    touch
  end

  def has_permission?(permission)
    power_user? || roles.collect(&:permissions).flatten.include?(permission)
  end

  def power_user?
    roles.collect(&:power_user?).include? true
  end

  def api_credential
    ApiCredential.find_or_create_by(organization_user: self) do |api_credential|
      api_credential.password          = SecureRandom.hex
      api_credential.organization_user = self
    end
  end

  def refresh_datacentred_api_credentials!
    new_password = SecureRandom.hex
    api_credential.update_attributes(password: new_password)
    new_password
  end

  def credentials_cache_key
    "ec2_credentials_#{id}_#{organization.id}"
  end

  def ec2_credentials
    cache = Rails.cache
    cache.delete(credentials_cache_key) unless cache.fetch(credentials_cache_key)
    cache.fetch(credentials_cache_key, expires_in: 30.days) do
      blob = _ec2_credentials.body['credentials'].first.try(:[], 'blob')
      blob ? JSON.parse(blob) : nil
    end
  end

  def refresh_ec2_credentials!
    _ec2_credentials.body['credentials'].each do |credential|
      OpenStackConnection.identity.delete_os_credential(credential['id'])
    end
    OpenStackConnection.identity.create_os_credential(user_id: user.uuid,
      project_id: organization.primary_project.uuid,
      type: 'ec2',
      blob: {'access' => SecureRandom.hex, 'secret' => SecureRandom.hex}.to_json)
    Rails.cache.delete(credentials_cache_key)
    remove_ceph_keys
    check_ceph_access
  end

  def self.create_admin(params)
    ou = create(params)
    if ou.save
      admin_role = ou.organization.roles.find_by(power_user: true)
      our = OrganizationUserRole.create(organization_user: ou, role: admin_role)
    end
    ou
  end

  private

  def _ec2_credentials
    OpenStackConnection.identity.list_os_credentials(user_id:    user.uuid,
                                                     project_id: organization.primary_project.uuid)
  end

  def set_primary
    update_column(:primary, true) if user.organizations.one? && user.organizations.first == organization
  end

  def check_if_primary_and_current_user
    if Authorization.current_user == user && primary?
      errors.add(:base, "You can't remove yourself from your primary account.")
      throw :abort
    end
  end

  def check_if_should_destroy_user
    if user.organizations.one? && Authorization.current_user != user
      user.destroy
    end
  end

  def check_if_temporary_membership_expired
    return unless persisted?
    if temporary? && expired?
      delete
      raise Stronghold::Error::TemporaryMembershipExpiredError,
            "Your temporary mermbership to #{organization.name} has expired."
    end
  end

  def check_openstack_access
    CheckOpenStackAccessJob.perform_later(self) unless Rails.env.test?
  end

  def check_ceph_access
    CheckCephAccessJob.perform_later(self) if Rails.env.production?
  end

  def check_datacentred_api_access
    CheckDataCentredApiAccessJob.perform_later(self) unless Rails.env.test?
  end

  def remove_from_openstack_and_ceph
    CheckOpenStackAccessJob.perform_now(self) unless Rails.env.test?
    CheckCephAccessJob.perform_now(self) if Rails.env.production?
  end

  def generate_ec2_credentials
    unless Rails.env.test?
      CreateEC2CredentialsJob.perform_later(self)
    end
  end

  def remove_ceph_keys
    if Rails.env.production?
      begin
        Ceph::UserKey.destroy 'access-key' => ec2_credentials['access'] if ec2_credentials
      rescue Net::HTTPError => error
        Honeybadger.notify(error) unless error.message.include? 'AccessDenied'
      end
    end
  end

end
