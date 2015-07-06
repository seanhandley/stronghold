require 'ostruct'

class Support::ManageCardsController < SupportBaseController
  include StripeHelper

  skip_authorization_check

  before_filter :check_self_service_and_power, :get_stripe_customer

  def index
    @cards = @stripe_customer.sources
  end

  def update
    rescue_stripe_errors(lambda {|msg| redirect_to support_manage_cards_path, alert: msg}) do
      @stripe_customer.default_source = params[:id]
      @stripe_customer.save
      redirect_to support_manage_cards_path, notice: "Card successfully set as default"
    end
  end

  def create
    rescue_stripe_errors(lambda {|msg| redirect_to support_manage_cards_path, alert: msg}) do
      card = @stripe_customer.sources.create(:source => create_params[:stripe_token])
      fingerprints = @stripe_customer.sources.collect(&:fingerprint)
      if fingerprints.include?(card.fingerprint)
        card.delete
        redirect_to support_manage_cards_path, alert: "You've already added that card"
      else
        Rails.cache.delete("org_#{current_user.organization.id}_has_payment_method")
        current_user.organization.has_payment_methods!(true)
        redirect_to support_manage_cards_path, notice: "New card added successfully"
      end
    end
  end

  def destroy
    rescue_stripe_errors(lambda {|msg| redirect_to support_manage_cards_path, alert: msg}) do
      if @stripe_customer.default_source != params[:id]
        @stripe_customer.sources.retrieve(params[:id]).delete
        redirect_to support_manage_cards_path
      else
        redirect_to support_manage_cards_path, alert: "You can't delete your default card. If you wish to remove a card, you must first add another."
      end
    end
  end

  private

  def get_stripe_customer
    @stripe_customer ||= rescue_stripe_errors(lambda {|msg| flash.now[:error] = msg; dummy_stripe}) do
      Stripe::Customer.retrieve(current_user.organization.stripe_customer_id)
    end
  end

  def create_params
    params.permit(:stripe_token)
  end

  def dummy_stripe
    OpenStruct.new(:sources => [])
  end

  def check_self_service_and_power
    raise ActionController::RoutingError.new('Not Found') unless current_user.power_user? && current_user.organization.self_service?
  end

end