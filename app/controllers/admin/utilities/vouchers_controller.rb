module Admin
  module Utilities
    class VouchersController < UtilitiesBaseController

      before_action :get_vouchers, only: [:index, :destroy]

      def index ; end

      def create
        @voucher = Voucher.new(create_params)
        ajax_response(@voucher, :save, admin_utilities_vouchers_path)
      end

      def update
        extend! and return if update_params[:extend]
        @voucher = Voucher.find(params[:id])
        ajax_response(@voucher, :update, admin_utilities_vouchers_path, update_params)
      end

      def destroy
        @voucher = Voucher.find(params[:id])
        if @voucher.destroy
          redirect_to admin_utilities_vouchers_path
        else
          flash[:error] = "You can't delete a voucher once it's been used by a customer."
          render :index
        end
      end

      private

      def extend!
        OrganizationVoucher.find(params[:id]).extend!
        redirect_to admin_utilities_vouchers_path, notice: 'Discount extended successfully'
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
  end
end
