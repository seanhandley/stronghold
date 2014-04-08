class DashboardController < ApplicationController

  def index
    render layout: false, text: "OK"
  end

end