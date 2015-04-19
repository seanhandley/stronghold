class Admin::VouchersController < AdminBaseController
  def index
    if params[:expired]
      @expired = Voucher.expired
    else
      @vouchers = Voucher.active
    end
  end
end