class AjaxController < ApplicationController
  include StripeHelper
    # Ajax
  def precheck
    rescue_stripe_errors(lambda {|msg| render json: {success: false, message: msg}}) do
      @customer_signup = CustomerSignup.find_by_uuid(precheck_params[:signup_uuid])
      unless @customer_signup.stripe_customer
        customer = Stripe::Customer.create(
          :source => precheck_params[:stripe_token],
          :email => @customer_signup.email,
          :description => "Company: #{@customer_signup.organization_name}, Signup UUID: #{@customer_signup.uuid}"
        )

        @customer_signup.update_attributes(stripe_customer_id: customer.id)
      end

      if @customer_signup.ready?    
        render json: {success: true, message: ''}
      else
        @customer_signup.update_attributes(stripe_customer_id: nil)
        render json: {success: false, message: @customer_signup.error_message}
      end
    end
  end

  def cc_submit
    @customer_signup = CustomerSignup.find_by_uuid(cc_submit_params[:signup_uuid])
    if @customer_signup
      @customer_signup.update_attributes(activation_attempts: @customer_signup.activation_attempts + 1)
    end
    head :no_content
  end

  private

  def precheck_params
    params.permit(:stripe_token, :signup_uuid, :stripe_customer_id)
  end

  def cc_submit_params
    params.permit(:signup_uuid)
  end
end