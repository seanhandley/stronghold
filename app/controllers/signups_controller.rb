class SignupsController < ApplicationController
  def update
    @signup = Signup.find(params[:id])
    if @signup.token == params[:token] && !@signup.complete?
      @signup.complete!
      redirect_to root_url
    else
      raise ActionController::RoutingError.new('Not Found')
    end   
  end
end