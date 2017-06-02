class OrganizationUser < ActiveRecord::Base

  self.table_name = 'organizations_users'
  after_initialize :check_if_temporary_membership_expired
  after_save :set_primary, on: :create
  before_destroy :check_if_should_destroy_user, :check_if_primary_and_current_user
  DEFAULT_MEMBERSHIP_DURATION_IN_HOURS = 4

  belongs_to :organization
  belongs_to :user

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

  private

  def set_primary
    update_column(:primary, true) if user.organizations.one?
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

end
