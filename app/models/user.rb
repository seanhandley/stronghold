class User < ActiveRecord::Base
  audited only: [:first_name, :last_name, :email]

  attr_accessor :password, :password_confirmation, :token

  syncs_with_salesforce as: 'Contact'

  def salesforce_args
    {
      Email: email,
      FirstName: first_name.present? ? first_name : nil,
      LastName: last_name.present? ? last_name : email,
      AccountId: organization.salesforce_id,
      Contact_Info__c: admin? ? 'Admin User' : 'Non-Admin User'
    }
  end

  authenticates_with_keystone

  after_save :update_password
  after_commit :generate_ec2_credentials, on: :create
  after_commit :check_openstack_access, :check_ceph_access, on: :create

  after_create :set_local_password, :subscribe_to_status_io
  before_destroy :dont_delete_self, :remove_ceph_keys, :unsubscribe_from_status_io
  syncs_with_keystone as: 'OpenStack::User', actions: [:create, :destroy]

  has_and_belongs_to_many :roles
  belongs_to :organization
  has_many :user_tenant_roles, dependent: :destroy
  has_many :tenants, :through => :user_tenant_roles

  validates :email, :uniqueness => true
  validates :email, :organization_id, :presence => true
  validates :password, :presence => true, :on => :create
  validate :password_complexity

  scope :active, -> { joins(:organization).where("organizations.disabled = ?", false)}

  def staff?
    organization.staff?
  end

  def cloud?
    organization.cloud?
  end

  def admin?
    roles.any?(&:power_user?)
  end

  def as_hash
    { email: email }
  end

  def keystone_params
    { email: email, name: email,
      enabled: organization.has_payment_method? && has_permission?('cloud.read'),
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

  def unique_id
    "#{organization.reporting_code} (User: #{id})"
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
      OpenStackConnection.identity.list_ec2_credentials(user_id: uuid).body['credentials'].first
    end
  end

  def refresh_ec2_credentials!   
    OpenStackConnection.identity.list_ec2_credentials(user_id: uuid).body['credentials'].each do |credential|
      OpenStackConnection.identity.delete_ec2_credential(uuid, credential['access'])
    end
    OpenStackConnection.identity.create_ec2_credential(uuid, organization.primary_tenant.uuid)
    Rails.cache.delete("ec2_credentials_#{id}")
    remove_ceph_keys
    check_ceph_access
  end

  def seen_online!
    Rails.cache.write("user_online_#{id}", true, expires_in: 5.minutes)
  end

  def online?
    !!Rails.cache.read("user_online_#{id}")
  end

  private

  def password_complexity
    if password.present?
      if password.length < 8
        errors.add(:base, I18n.t(:password_too_short))
      end
    end
  end

  def update_password
    if password.present? && uuid
      OpenStack::User.update_password uuid, password
      set_local_password
    end
  end

  def generate_ec2_credentials
    unless Rails.env.test? || Rails.env.staging?
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
    CheckCephAccessJob.perform_later(self)
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
      false
    end
  end

end