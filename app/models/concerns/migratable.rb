module Migratable

  def migrate!
    update_attributes(self_service: !self_service?)
    self_service? ? migrate_self_service_to_invoiced : migrate_invoiced_to_self_service
    true
  end

  private

  def migrate_self_service_to_invoiced
    ActivateCloudResourcesJob.perform_later(self) if state == OrganizationStates::Fresh
  end

  def migrate_invoiced_to_self_service
    unless customer_signup
      CustomerSignup.skip_callback(:commit, :after, :send_email)
      customer_signup = CustomerSignup.create(email: admin_users.first.email,
                          organization_name: name, ip_address: nil)
      CustomerSignup.set_callback(:commit, :after, :send_email)
      update_attributes(customer_signup: customer_signup)
    end
  end

end