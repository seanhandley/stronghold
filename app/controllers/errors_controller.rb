class ErrorsController < ApplicationController

  layout 'error'

  def page_not_found ; end
  def server_error ; end

end