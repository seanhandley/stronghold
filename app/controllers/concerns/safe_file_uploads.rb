module SafeFileUploads
  extend ActiveSupport::Concern

  included do
    before_action :check_upload_token, only: [:create, :update, :destroy]
    helper_method :safe_upload_token
  end

  def safe_upload_token
    current_token
  end

  def check_upload_token
    if upload_params[:safe_upload_token] == current_token
      Rails.cache.delete(token_key)
    else
      slow_404
    end
  end

  def current_token
    Rails.cache.fetch(token_key, expires_in: 8.hours) do
      SecureRandom.hex
    end
  end

  def clear_token
    Rails.cache.delete token_key
  end

  def token_key
    "safe_upload_token_#{current_organization.id}_#{current_user.id}"
  end

  def upload_params
    params.permit(:ticket_id, :file, :safe_upload_token)
  end

end
