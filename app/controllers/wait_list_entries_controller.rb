class WaitListEntriesController < ApplicationController
  include ModelErrorsHelper

  layout "customer-sign-up"

  def create
    @wait_list_entry = WaitListEntry.new(create_params)
    if @wait_list_entry.save
      render 'signups/confirm_wait'
    else
      flash[:error] = model_errors_as_html(@wait_list_entry)
      render 'signups/sorry'
    end
  end

  private

  def create_params
    params.permit(:email)
  end

end
