require_relative "./staff_constraint"

class ClientCertConstraint
  def matches?(request)
    Rails.logger.debug '*****'
    Rails.logger.debug request.host
    return true  unless Rails.env.production?
    return false unless request.host == 'admin-my.datacentred.io'
    return false unless StaffConstraint.new.matches?(request)
    return true
  end
end
