class Admin::VouchersController < AdminBaseController

  before_filter :get_vouchers, only: [:index, :destroy]

  def index
    
  end

  def create
    @voucher = Voucher.new(create_params)
    if @voucher.save
      javascript_redirect_to admin_vouchers_path
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @voucher } }
      end
    end
  end

  def update
    extend! and return if update_params[:extend]
    @voucher = Voucher.find(params[:id])
    if @voucher.update(update_params)
      javascript_redirect_to admin_vouchers_path
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @voucher } }
      end
    end   
  end

  def destroy
    @voucher = Voucher.find(params[:id])
    if @voucher.destroy
      redirect_to admin_vouchers_path
    else
      flash[:error] = "You can't delete a voucher once it's been used by a customer."
      render :index
    end  
  end

  private

  def extend!
    OrganizationVoucher.find(params[:id]).extend!
    redirect_to admin_vouchers_path, notice: 'Discount extended successfully'
  end

  def create_params
    params.require(:voucher).permit(:name, :description, :code,
                                    :discount_percent, :duration,
                                    :expires_at, :usage_limit,
                                    :restricted)
  end

  def update_params
    params.permit(:expires_at, :extend)
  end

  def get_vouchers
    @vouchers ||= params[:expired] ? Voucher.expired : Voucher.active
  end
  
end