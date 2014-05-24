class Support::InstancesController < SupportBaseController

  load_and_authorize_resource

  def index
    @instances = Instance.all
  end
end