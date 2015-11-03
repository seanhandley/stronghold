class Admin::BillingRatesController < AdminBaseController

  def index
    @billing_rates = Billing::Rate.all || []
  end

  def update
    @rate = Billing::Rate.find params[:id]
    if @rate.update(update_params)
      respond_to do |format|
        format.js { render :template => "shared/dialog_success", :locals => {:object => @rate, :message => "Saved" } }
      end
    else
      respond_to do |format|
        format.js { render :template => "shared/dialog_errors", :locals => {:object => @rate } }
      end
    end
  end

  def update_params
    params.require(:billing_rate).permit(:rate)
  end

end
