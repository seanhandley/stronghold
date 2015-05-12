class WaitListEntriesController < ApplicationController

  layout "customer-sign-up"

  def create
    @wait_list_entry = WaitListEntry.new(create_params)
    if @wait_list_entry.save
      render 'signups/confirm_wait'
    else
      flash[:error] = @wait_list_entry.errors.full_messages.join('<br>').html_safe
      render 'signups/sorry'
    end
  end

  private

  def create_params
    params.permit(:email)
  end

end