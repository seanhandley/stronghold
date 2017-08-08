module Admin
  class CustomersController < AdminBaseController
    include TicketsHelper
    include ModelErrorsHelper

    before_action :get_products
    before_action :get_organization
    before_action :get_products

    def new
      @customer = CustomerGenerator.new
    end

    def create
      @customer = CustomerGenerator.new(create_params)
      @organization = Organization.new(create_params[:organization])
      if @customer.generate!
        redirect_to admin_root_path, notice: 'Customer created successfully'
      else
        flash[:error] = model_errors_as_html(@customer)
        render :new
      end
    end

    def index
    end

    def show
      @organization       = Organization.find(params[:id]) if params[:id]
      @usage_decorator    = UsageDecorator.new(@organization)
      @tickets            = decorated_tickets(@organization)
      @organization_users = @organization.organization_users
      @audits             = Audit.for_organization_and_user(@organization, current_user).order('created_at DESC').first(7)
      @projects           = @organization.projects.includes(:users)
      @invites            = @organization.invites.incomplete
      @staff_membership   = OrganizationUser.find_by(organization: @organization, user: current_user)
    end

    def edit
      @organization = Organization.find(params[:id])
    end

    def update
      organization = Organization.find(params[:id])

      if organization.update_including_state(sanitised_update_params)
        respond_to do |format|
          format.js {
            javascript_redirect_to admin_customer_path(organization)
          }
          format.html {
            redirect_to edit_admin_customer_path(organization), notice: "Saved successfully"
          }
        end
      else
        respond_to do |format|
          format.js {
            render json: {'message': organization.errors.full_messages.join}, status: :unprocessable_entity
          }
          format.html {
            redirect_to edit_admin_customer_path(organization), alert: organization.errors.full_messages.join
          }
        end
      end
    end

    private

    def create_params
      params.permit(:organization_name, :email, :extra_projects, :salesforce_id,
                    :organization => {:product_ids => []})
    end

    def update_params
      params.require(:organization).permit(:name, :reporting_code, :reference, :billing_contact, :stripe_customer_id, :salesforce_id,
                                           :billing_address1, :billing_city, :billing_postcode,
                                           :billing_country, :phone, :state, :id, :started_paying_at,
                                           :test_account, :bill_automatically)
    end

    def sanitised_update_params
      return update_params unless update_params[:started_paying_at]
      update_params.merge(started_paying_at: update_params[:started_paying_at] == '1' ? Time.now : nil)
    end

    def get_products
      @products ||= Product.all
    end

    def get_organization
      @organization = Organization.find(params[:id]) if params[:id]
    end
  end
end
