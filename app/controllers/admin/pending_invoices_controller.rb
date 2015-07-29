class Admin::PendingInvoicesController < AdminBaseController

  def index
    @pending_invoices = Billing::Invoice.unfinalized
  end

  def update
    
  end

end
