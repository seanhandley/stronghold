class OrganizationVoucher < ActiveRecord::Base
  belongs_to :organization
  belongs_to :voucher

  validate -> { errors.add(:base, "Voucher has expired") if voucher.expired? }

  def active?
    created_at + voucher.duration.months > Time.now.utc
  end
end
