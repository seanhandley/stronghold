module Admin
  class FrozenCustomersController < AdminBaseController
    before_action :fetch_organization

    def fetch_organization
      @organization = Organization.find(params[:id])
    end

    def index
    end

    def update
      if @organization.unfreeze!
        Mailer.review_mode_successful(@organization).deliver_now
        redirect_to admin_customer_path(@organization), notice: "Customer has been unfrozen."
      else
        redirect_to admin_customer_path(@organization), alert: "Couldn't unfreeze!"
      end
    end

    def mail
      fc = FraudCheck.new(@organization.customer_signup)
      Mailer.fraud_check_alert(@organization.customer_signup, fc, current_user.email).deliver_now
      redirect_to admin_customer_path(@organization), notice: "Email delivered."
    end

    def charge
      status, message = AntiFraud.test_charge_succeeds?(@organization)
      if status
        redirect_to admin_customer_path(@organization), notice: 'Success. The amount of £1 was charged and refunded to the customer.'
      else
        redirect_to admin_customer_path(@organization), alert: "Failed. Payment provider says: #{message}"
      end
    end

  end
end
