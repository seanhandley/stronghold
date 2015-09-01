module GravatarHelper
  def cached_gravatar_image(key, params={})
    Rails.cache.fetch("gravatar_#{key}", expires_in: 20.minutes) do
      gravatar_image_tag(key, params)
    end
  end
end