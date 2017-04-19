class OrganizationUser < ActiveRecord::Base
  self.table_name = 'organizations_users'
  after_save :set_primary, on: :create
  before_destroy :check_if_primary_and_current_user #:check_if_should_destroy_user

  belongs_to :organization
  belongs_to :user

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

end
