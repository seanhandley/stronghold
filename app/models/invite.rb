class Invite < ActiveRecord::Base
  include Gravatar

  audited only: [:email]

  after_create :generate_token
  after_commit :send_email, on: :create

  validates :email, length: {minimum: 5}, allow_blank: false
  validates :organization, :presence => true
  validate :has_roles?
  validate :email_looks_valid?
  validate :no_user_has_that_email?
  validate :role_ids_belong?
  validate :project_ids_belong?

  belongs_to :organization
  belongs_to :customer_signup
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :projects, validate: false

  def can_register?
    if active? && !complete?
      true
    else
      false
    end
  end

  def complete!
    update_attributes(completed_at: Time.now)
  end

  def resend!
    update_attributes(created_at: Time.now)
    send_email
  end

  def expires_at
    persisted? ? created_at + 7.days : Time.now + 7.days
  end

  def delivery_status
    return "pending" unless remote_message
    remote_message.status
  end

  private

  def remote_message
    @remote_message ||= Timeout::timeout(2) { Deliverhq::Message.find(remote_message_id) }
  rescue Deliverhq::RequestError, Timeout::Error
    nil
  end

  def complete?
    !!completed_at
  end

  def active?
    !complete? && (expires_at > Time.now)
  end

  def generate_token
    return if token
    update_column(:token, SecureRandom.urlsafe_base64)
  end

  def has_roles?
    errors.add(:base, I18n.t(:please_give_user_at_least_one_role)) unless power_invite? || roles.present?
  end

  def email_looks_valid?
    errors.add(:email, I18n.t(:is_not_a_valid_address)) unless email =~ /.+@.+\..+/
  end

  def no_user_has_that_email?
    errors.add(:email, 'already has an account. Please choose another email.') if email.present? && User.find_by_email(email.downcase) && !persisted?
  end

  def role_ids_belong?
    roles.each do |role|
      unless role.organization_id == organization_id
        errors.add(:base, 'Invalid roles supplied. Please select valid roles for this user.')
      end
    end
  end

  def project_ids_belong?
    projects.each do |project|
      unless project.organization_id == organization_id
        errors.add(:base, 'Invalid projects supplied. Please select valid projects for this user.')
      end
    end
  end

  def send_email
    DeliverhqMailJob.perform_later(self)
  end
end
