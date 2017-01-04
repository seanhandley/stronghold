class Reset < ApplicationRecord

  audited only: [:email, :completed_at, :created_at]

  after_create :generate_token

  validates :email, length: {minimum: 5}, allow_blank: false
  validate :email_looks_valid?

  def user_exists?
    !!user
  end

  def user
    User.find_by_email(email)
  end

  def expires_at
    persisted? ? created_at + 72.hours : Time.now + 72.hours
  end

  def expired?
    expires_at < Time.now || completed_at
  end

  def update_password(params)
    password = params[:password]
    if expired?
      errors.add :base, I18n.t(:signup_token_not_valid)
    elsif password.length < 8
      errors.add :base,  I18n.t(:password_too_short)
    else
      user.update_attributes(password: password)
      update_column(:completed_at, Time.now)
      return true
    end
    return false
  end

  private

  def generate_token
    return if token
    update_column(:token, SecureRandom.urlsafe_base64)
  end

  def email_looks_valid?
    unless email =~ /.+@.+\..+/
      errors.add(:email, I18n.t(:is_not_a_valid_address)) 
      throw :abort
    end
  end

end
