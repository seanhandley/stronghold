module Gravatar
  def gravatar_hash
    Rails.cache.fetch("gravatar_hash_#{email}", expires_in: 1.hour) do
      Digest::MD5.hexdigest(email)
    end
  end
end
