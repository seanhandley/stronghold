module Admin
  module Utilities
    class PendingInvoicesController < UtilitiesBaseController

      def index
        if show_finalized?
          @finalized_invoices = Billing::Invoice.finalized  
        else
          @pending_invoices = Billing::Invoice.unfinalized
        end
        
      end

      def update
        @invoice = Billing::Invoice.find(params[:id])
        @invoice.update(update_params)
        ajax_response(@invoice, :finalize!, admin_utilities_pending_invoices_path)
      end

      def destroy
        @invoice = Billing::Invoice.find(params[:id])
        if @invoice.destroy
          redirect_to admin_utilities_pending_invoices_path
        else
          redirect_to admin_utilities_pending_invoices_path, alert: "Couldn't destroy invoice"
        end
      end

      private

      def update_params
        params.require(:billing_invoice).permit(:salesforce_invoice_id, :grand_total)
      end

      def show_finalized?
        !!params[:finalized]
      end

    end
  end
end
