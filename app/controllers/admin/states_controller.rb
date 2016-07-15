class Admin::StatesController < AdminBaseController
  def show
    @organization = Organization.find(params[:id])
    @transitions = @organization.transitions.order('created_at desc')
  end
end
