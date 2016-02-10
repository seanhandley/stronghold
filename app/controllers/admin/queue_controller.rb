class Admin::QueueController < AdminBaseController
  include SidekiqControlHelper

  def index ; end

  def restart
    restart_sidekiq
    respond_to do |format|
      format.js {
        render :template => "shared/dialog_info", :locals => {:message => restart_message }
      }
    end 
  end
end