class Admin::FrozenCustomersController < AdminBaseController

  def index
    @frozen_customers = Organization.frozen.reverse
  end

  def update
    organization = Organization.find(params[:id])
    if organization.unfreeze!
      Mailer.review_mode_successful(organization).deliver_later
      redirect_to admin_frozen_customers_path, notice: "Customer has been unfrozen."  
    else
      redirect_to admin_frozen_customers_path, alert: "Couldn't unfreeze!"
    end
  end

  def mail
    organization = Organization.find(params[:id])
    fc = FraudCheck.new(organization.customer_signup)
    Mailer.fraud_check_alert(organization.customer_signup, fc, current_user.email).deliver_now
    redirect_to admin_frozen_customers_path, notice: "Email delivered."
  end

end
