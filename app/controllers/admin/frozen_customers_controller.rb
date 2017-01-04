module Admin
  class FrozenCustomersController < AdminBaseController

    def index
    end

    def update
      @organization = Organization.find(params[:id])

      if @organization.unfreeze!
        Mailer.review_mode_successful(@organization).deliver_later
        redirect_to admin_customer_path, notice: "Customer has been unfrozen."
      else
        redirect_to admin_customer_path, alert: "Couldn't unfreeze!"
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
        redirect_to admin_frozen_customers_path, notice: 'Success. The amount of £1 was charged and refunded to the customer.'
      else
        redirect_to admin_frozen_customers_path, alert: "Failed. Payment provider says: #{message}"
      end
    end

  end
end
