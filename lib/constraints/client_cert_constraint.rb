class ClientCertConstraint
  def matches?(request)
    return true  unless Rails.env.production?
    return false unless request.host == 'admin-my.datacentred.io'
    return true
  end
end
