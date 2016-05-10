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

  def destroy
    organization = Organization.find(params[:id])
    if organization.destroy
      redirect_to admin_frozen_customers_path, notice: "Customer has been deleted."
    else
      redirect_to admin_frozen_customers_path, alert: "Couldn't delete!"
    end
  end

  def mail
    organization = Organization.find(params[:id])
    fc = FraudCheck.new(organization.customer_signup)
    Mailer.fraud_check_alert(organization.customer_signup, fc, current_user.email).deliver_now
    redirect_to admin_frozen_customers_path, notice: "Email delivered."
  end

  def charge
    organization = Organization.find(params[:id])
    status, message = AntiFraud.test_charge_succeeds?(organization)
    if status
      redirect_to admin_frozen_customers_path, notice: 'Success. The amount of 1£ was charged and refounded to the customer.'
    else
      redirect_to admin_frozen_customers_path, notice: "Failed. Couldn't charge the customer"
    end
  end

end
