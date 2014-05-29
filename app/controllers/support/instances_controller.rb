class Support::InstancesController < SupportBaseController

  load_and_authorize_resource :class => "OpenStack::Instance"

  def index
    @instances = OpenStack::Instance.all
  end
end