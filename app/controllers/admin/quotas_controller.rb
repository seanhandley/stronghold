module Admin
  class QuotasController < AdminBaseController

    # This QuotasController class is responsible for coordinating organizations quotas.
    before_action :find_organization

    def edit ; end

    def update
      begin
        attrs = {
          limited_storage: storage_params[:limited_storage] ? true : false,
          quota_limit: quota_params.to_h,
          projects_limit: organization_params[:projects_limit]
        }
        @organization.update_attributes(attrs)
        redirect_to edit_admin_quota_path(@organization), notice: 'Saved'
      rescue ArgumentError => error
        redirect_to edit_admin_quota_path(@organization), notice: error.message
      end
    end

    private

    def find_organization
      @organization ||= Organization.find(params[:id]) if params[:id]
    end

    def services_quotas
      @compute_quota = StartingQuota['standard']['compute'].keys.map(&:to_sym)
      @volume_quota = StartingQuota['standard']['volume'].keys.map(&:to_sym)
      @network_quota = StartingQuota['standard']['network'].keys.map(&:to_sym)
    end

    def quota_params
      params.require(:quota).permit(:compute => @compute_quota,
                                    :volume => @volume_quota,
                                    :network => @network_quota)
    end

    def storage_params
      params.permit(:limited_storage)
    end

    def organization_params
      params.require(:organization).permit(:projects_limit)
    end

  end
end
