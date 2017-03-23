class OrganizationVoucher < ApplicationRecord
  belongs_to :organization
  belongs_to :voucher

  validate -> { errors.add(:base, "Discount code has expired") if voucher.expired? }

  default_scope -> { order(:updated_at) }

  def active?
    expires_at > Time.now.utc
  end

  def expires_at
    updated_at + voucher.duration.days
  end

  def extend!
    touch
  end
end
