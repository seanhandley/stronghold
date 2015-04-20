class OrganizationVoucher < ActiveRecord::Base
  belongs_to :organization
  belongs_to :voucher

  validate -> { errors.add(:base, "Discount code has expired") if voucher.expired? }

  default_scope -> { order(:created_at) }

  def active?
    created_at + voucher.duration.months > Time.now.utc
  end
end
