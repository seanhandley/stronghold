class Admin::VouchersController < AdminBaseController
  def index
    @vouchers = params[:expired] ? Voucher.expired : Voucher.active
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
    @voucher = Voucher.find(params[:id])
    if @voucher.update(update_params)
      javascript_redirect_to admin_vouchers_path
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @voucher } }
      end
    end   
  end

  private

  def create_params
    params.require(:voucher).permit(:name, :description, :code,
                                    :discount_percent, :duration,
                                    :expires_at)
  end

  def update_params
    params.permit(:expires_at)
  end
end