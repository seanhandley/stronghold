class VouchersController < ApplicationController
  def precheck
    @voucher = Voucher.find_by_code precheck_params[:code]

    if @voucher
      if @voucher.expired?
        render json: {success: false, message: 'Sorry, that code has expired!'}
      else
        render json: {success: true, message: @voucher.description}
      end
    else
      render json: {success: false, message: 'Sorry, that code is invalid!'}
    end
  end

  private

  def precheck_params
    params.permit(:code)
  end
end