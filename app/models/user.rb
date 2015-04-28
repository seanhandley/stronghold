class User < ActiveRecord::Base
  audited only: [:first_name, :last_name, :email]

  attr_accessor :password, :password_confirmation, :token

  authenticates_with_keystone
  syncs_with_keystone as: 'OpenStack::User', actions: [:create]
  after_save :update_password
  after_create :generate_ec2_credentials
  after_create :subscribe_to_status_io

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
      enabled: true,
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

  private

  def password_complexity
    if password.present? && password.length < 8
      errors.add(:base, I18n.t(:password_too_short))
    end
  end

  def update_password
    if password
      OpenStack::User.update_password uuid, password
    end
  end

  def generate_ec2_credentials
    unless Rails.env.test? || Rails.env.staging?
      organization.tenants.each do |tenant|
        credential = Fog::Identity.new(OPENSTACK_ARGS).create_ec2_credential(uuid, tenant.uuid).body['credential']
        Ceph::UserKey.create 'uid' => tenant.uuid, 'access-key' => credential['access'], 'secret-key' => credential['secret']
      end
    end
  end

  def subscribe_to_status_io
    unless Rails.env.test? || Rails.env.staging?
      StatusIO.add_subscriber email
    end
  end

end