class ErrorsController < ApplicationController

  layout 'error'

  def page_not_found
    render :status => 404, :formats => [:html]
  end

  def server_error
    render :status => 500, :formats => [:html]
  end

  def boom
    1 / 0
  end

end