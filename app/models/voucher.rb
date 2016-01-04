class Voucher < ApplicationRecord
  has_many :organization_vouchers, {dependent: :destroy}, -> { distinct }
  has_many :organizations, :through => :organization_vouchers

  before_validation :create_code, on: :create
  before_destroy :check_applied, prepend: true

  validates :name, :description, :code,
            :duration, :discount_percent,
            presence: true, allow_blank: false

  validates :code, uniqueness: true
  validates :duration, numericality: { only_integer: true, greater_than: 0 }
  validates :usage_limit, numericality: { only_integer: true, greater_than: 0, :allow_nil => true }
  validates :discount_percent, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validate -> { errors.add(:expires_at, "is in the past") if expired? }, on: :create

  scope :active,  -> { where('expires_at > ? OR expires_at IS NULL', Time.now.utc) }
  scope :expired, -> { where('expires_at <= ?', Time.now.utc) }

  def expired?
    return true if remaining_uses == 0
    return false unless expires_at
    expires_at < Time.now.utc
  end

  def applied?
    organizations.count > 0
  end

  def remaining_uses
    return Float::INFINITY unless usage_limit
    usage_limit - organization_vouchers.count
  end

  private

  def create_code
    return if code.present?

    self.code = random_code
  end

  def random_code
    c = (0...8).map { ('a'..'z').to_a[rand(26)] }.join.upcase
    return random_code if Voucher.find_by_code(c)
    c
  end

  def check_applied
    if applied?
      errors.add(:base, "You can't delete a voucher that's been used by a customer.")
      throw :abort
    end
  end

end
