class User < ActiveRecord::Base
  audited only: [:first_name, :last_name, :email]

  attr_accessor :password, :password_confirmation, :token

  authenticates_with_keystone
  syncs_with_keystone as: 'OpenStack::User', actions: [:create, :destroy]
  after_save :update_password
  after_create :generate_ec2_credentials, :set_local_password

  has_and_belongs_to_many :roles
  belongs_to :organization
  has_many :user_tenant_roles, dependent: :destroy
  has_many :tenants, :through => :user_tenant_roles

  validates :email, :uniqueness => true
  validates :email, :organization_id, :presence => true
  validates :first_name, :last_name, length: {minimum: 1}, allow_blank: false
  validates :password, :presence => true, :on => :create
  validate :password_complexity, :on => :create

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

  def unique_id
    "stronghold_#{id}"
  end

  def keystone_params
    { email: email, name: email,
      tenant_id: organization.primary_tenant.uuid,
      enabled: false,
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

  def authenticate_local(unencrypted_password)
    BCrypt::Password.new(password_digest) == unencrypted_password && self
  end

  private

  def password_complexity
    if password.present? && password.length < 8
      errors.add(:base, I18n.t(:password_too_short))
    end
  end

  def set_local_password
    if password.present?
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      update_column(:password_digest, BCrypt::Password.create(password, cost: cost))
    end
  end

  def update_password
    if password.present?
      OpenStack::User.update_password uuid, password
      set_local_password
    end
  end

  def generate_ec2_credentials
    unless Rails.env.test?
      organization.tenants.each do |tenant|
        credential = Fog::Identity.new(OPENSTACK_ARGS).create_ec2_credential(uuid, tenant.uuid).body['credential']
        Ceph::UserKey.create 'uid' => tenant.uuid, 'access-key' => credential['access'], 'secret-key' => credential['secret']
      end
    end
  end

end