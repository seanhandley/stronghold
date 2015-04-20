class VouchersController < ApplicationController
  def precheck
    @voucher = Voucher.find_by_code precheck_params[:code]

    if @voucher 
      render json: {success: true, message: @voucher.description}
    else
      render json: {success: false, message: 'Discount code not found'}
    end
  end

  private

  def precheck_params
    params.permit(:code)
  end
end