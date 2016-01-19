require_relative "./staff_constraint"

class ClientCertConstraint
  def matches?(request)
    return true  unless Rails.env.production?
    return false unless request.host == 'admin-my.datacentred.io'
    return false unless StaffConstraint.new.matches?(request)
  end
end
