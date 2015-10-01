class Admin::PendingInvoicesController < AdminBaseController

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
    if @invoice.finalize!
      javascript_redirect_to admin_pending_invoices_path
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @invoice } }
      end
    end
  end

  private

  def update_params
    params.require(:billing_invoice).permit(:salesforce_invoice_id, :sub_total,
      :grand_total, :tax_percent, :discount_percent)
  end

  def show_finalized?
    !!params[:finalized]
  end

end
