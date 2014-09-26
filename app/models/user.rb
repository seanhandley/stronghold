class User < ActiveRecord::Base
  audited only: [:first_name, :last_name, :email]

  has_secure_password
  encrypt_with_public_key :api_key,
    :key_pair => Rails.root.join('config','keypair.pem')

  has_and_belongs_to_many :roles
  belongs_to :organization

  validates :email, :uniqueness => true
  validates :email, :presence => true
  validates :password, :presence => true, :on => :create
  validate :password_complexity

  before_save :set_os_user, if: -> { SyncWithOpenStack }

  def staff?
    organization.staff?
  end

  def unique_id
    "stronghold_#{id}"
  end

  def as_hash
    { email: email }
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

  def openstack_username
    "#{organization.reference}_#{email}"
  end

  private

  def password_complexity
    if password.present? && password.length < 8
      errors.add(:base, I18n.t(:password_too_short))
    end
  end

  def set_os_user
    params =  { email: email, name: "#{organization.reference}_#{email}",
                tenant_id: organization.tenant_id,
                enabled: true
              }
    if new_record?
      new_key = SecureRandom.hex
      self.api_key = new_key
      params[:password] = new_key
      u = OpenStack::User.create params
      self.openstack_id = u.id
    else
      # Needs to be an admin user to change identity details
      #
      # u = OpenStack::User.find_all_by(:id, openstack_id)[0]
      # u.update params
    end
  end

end