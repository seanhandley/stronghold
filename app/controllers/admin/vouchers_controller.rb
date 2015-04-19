class Admin::VouchersController < AdminBaseController
  def index
    @vouchers = params[:expired] ? Voucher.expired : Voucher.active
  end
end