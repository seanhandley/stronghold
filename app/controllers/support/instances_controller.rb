module Support
  class InstancesController < SupportBaseController

    load_and_authorize_resource :class => "OpenStack::Instance"

    def current_section
      'instances'
    end

    def index
      @instances = OpenStack::Instance.all
    end
  end
end
