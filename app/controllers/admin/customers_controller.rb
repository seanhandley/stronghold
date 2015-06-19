class Admin::CustomersController < AdminBaseController

  before_filter :get_products

  def new
    @customer = CustomerGenerator.new
  end

  def create
    @customer = CustomerGenerator.new(create_params)
    @organization = Organization.new(create_params[:organization])
    if @customer.generate!
      redirect_to admin_root_path, notice: 'Customer created successfully'
    else
      flash[:error] = @customer.errors.full_messages.join('<br>')
      render :new
    end
  end

  private

  def create_params
    params.permit(:organization_name, :email, :extra_tenants, :salesforce_id,
                  :organization => {:product_ids => []})
  end

  def get_products
    @products ||= Product.all
  end
end