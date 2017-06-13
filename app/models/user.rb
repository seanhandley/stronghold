class User < ApplicationRecord
  include Trackable
  include Gravatar
  include UserPreferences

  audited only: [:first_name, :last_name, :email]
  has_associated_audits

  attr_accessor :password, :password_confirmation, :token
  attr_readonly :email

  syncs_with_salesforce as: 'Contact', actions: [:create, :update]

  def salesforce_args
    {
      Email: email,
      FirstName: first_name.present? ? first_name : nil,
      LastName: last_name.present? ? last_name : email,
      AccountId: current_organization.salesforce_id,
      Contact_Info__c: admin? ? 'Admin User' : 'Non-Admin User'
    }
  end

  authenticates_with_keystone

  before_save :valid_email_address
  after_save :update_password
  after_commit :generate_ec2_credentials, on: :create
  after_commit :check_openstack_access, :check_ceph_access, on: :create

  after_create :set_local_password, :subscribe_to_status_io
  before_destroy :dont_delete_self, :remove_ceph_keys, :unsubscribe_from_status_io
  syncs_with_keystone as: 'OpenStack::User', actions: [:create, :destroy]

  has_and_belongs_to_many :roles
  has_many :organization_users, dependent: :destroy
  has_many :organizations, through: :organization_users
  has_many :user_project_roles, dependent: :destroy
  has_many :projects, :through => :user_project_roles
  has_many :unread_tickets
  has_many :api_credentials

  validates :email, :uniqueness => true
  validates :email, :presence => true
  validates :password, :presence => true, :on => :create
  validate :password_complexity
  validate :valid_email_address

  scope :active,  -> { joins(:organizations).where("organizations.disabled = ?", false).distinct }

  def staff?
    organizations.any?(&:staff?)
  end

  def cloud?
    current_organization.cloud?
  end

  def compute?
    current_organization.compute?
  end

  def storage?
    current_organization.storage?
  end

  def colo?
    current_organization.colo?
  end

  def admin?
    roles.any?(&:power_user?)
  end

  def belongs_to_multiple_organizations?
    organizations.many?
  end

  def primary_organization
    ous = OrganizationUser.where(user: self)
    organization_user  = (ous.find_by(primary: true) || ous.first)
    organization_user&.organization
  end

  def current_organization
    Authorization.current_organization || primary_organization
  end

  def as_hash
    { email: email }
  end

  def keystone_params
    { email: email, name: email,
      enabled: current_organization.has_payment_method? && has_permission?('cloud.read'),
      password: password
    }
  end

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

  def authenticate(unencrypted_password)
    setup_password_from_openstack(unencrypted_password) unless password_digest.present?
    begin
      authed = BCrypt::Password.new(password_digest) == unencrypted_password && self
    rescue BCrypt::Errors::InvalidHash
      authed = false
    end

    if authed
      token = authenticate_openstack(unencrypted_password)
    end
    token || authed
  end

  def setup_password_from_openstack(unencrypted_password)
    if authenticate_openstack(unencrypted_password)
      set_local_password(unencrypted_password)
    end
  end

  def set_local_password(new_password=nil)
    if new_password
      password = new_password
    else
      password = self.password
    end
    if password.present?
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      update_column(:password_digest, BCrypt::Password.create(password, cost: cost))
    end
  end

  def ec2_credentials
    cache = Rails.cache
    cache.delete("ec2_credentials_#{id}") unless cache.fetch("ec2_credentials_#{id}")
    cache.fetch("ec2_credentials_#{id}", expires_in: 30.days) do
      blob = OpenStackConnection.identity.list_os_credentials(user_id: uuid).body['credentials'].first.try(:[], 'blob')
      blob ? JSON.parse(blob) : nil
    end
  end

  def refresh_ec2_credentials!
    OpenStackConnection.identity.list_os_credentials(user_id: uuid).body['credentials'].each do |credential|
      OpenStackConnection.identity.delete_os_credential(credential['id'])
    end
    OpenStackConnection.identity.create_os_credential(user_id: uuid,
      project_id: Authorization.current_organization.primary_project.uuid,
      type: 'ec2',
      blob: {'access' => SecureRandom.hex, 'secret' => SecureRandom.hex}.to_json)
    Rails.cache.delete("ec2_credentials_#{id}")
    remove_ceph_keys
    check_ceph_access
  end

  def api_credential
    api_credentials.find_by(organization: current_organization) || api_credentials.create!(password: SecureRandom.hex, organization: current_organization)
  end

  def refresh_datacentred_api_credentials!
    new_password = SecureRandom.hex
    api_credential.update_attributes(password: new_password)
    new_password
  end

  private

  def password_complexity
    if password
      if password.length < 8
        errors.add(:base, I18n.t(:password_too_short))
        throw :abort
      end
    end
  end

  def valid_email_address
    unless email =~ /.+@.+\..+/
      errors.add(:email, I18n.t(:is_not_a_valid_address))
      throw :abort
    end
    unless email.length >= 5
      errors.add(:email, I18n.t(:is_not_a_valid_address))
      throw :abort
    end
  end

  def update_password
    if password.present? && uuid
      OpenStack::User.update_password uuid, password
      set_local_password
    end
  end

  def generate_ec2_credentials
    unless Rails.env.test?
      CreateEC2CredentialsJob.perform_later(self)
    end
  end

  def subscribe_to_status_io
    if Rails.env.production?
      StatusIOSubscribeJob.perform_later('add_subscriber', email)
    end
  end

  def unsubscribe_from_status_io
    if Rails.env.production?
      StatusIOSubscribeJob.perform_later('remove_subscriber', email)
    end
  end

  def check_openstack_access
    CheckOpenStackAccessJob.perform_later(self) unless Rails.env.test?
  end

  def check_ceph_access
    CheckCephAccessJob.perform_later(self) if Rails.env.production?
  end

  def remove_ceph_keys
    if Rails.env.production?
      begin
        Ceph::UserKey.destroy 'access-key' => self.ec2_credentials['access'] if self.ec2_credentials
      rescue Net::HTTPError => error
        Honeybadger.notify(error) unless error.message.include? 'AccessDenied'
      end
    end
  end

  def dont_delete_self
    if Authorization.current_user && Authorization.current_user.id == id
      errors.add(:base, "You can't delete yourself!")
      throw :abort
    end
  end

end
