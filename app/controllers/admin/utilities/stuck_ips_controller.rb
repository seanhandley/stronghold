class Admin::Utilities::StuckIpsController < UtilitiesBaseController
  def index
    @stuck_ips = Reaper.new.stuck_in_an_instance
  end

  def destroy
    Reaper.new.remove_stuck_ip_from_instance(params[:id], destroy_params[:ip_address])
    redirect_to admin_utilities_stuck_ips_path
  end

  private

  def destroy_params
    params.permit(:ip_address)
  end
end
