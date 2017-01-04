# See http://sirportly.com/docs/admin/advanced-features/customer-data-sources
module Ext
  class ContactsController < ActionController::Base
    skip_authorization_check
    skip_before_action :verify_authenticity_token, :only => [:find], raise: false

    def find
      if find_params[:type] == "email" && user = User.find_by_email(find_params[:data])
        render json: UserDecorator.new(user).as_sirportly_data.to_json
      else
        render json: nil.to_json, status: :not_found    
      end
    end

    private

    def find_params
      params.permit(:type, :data)
    end

    def current_user
      nil
    end
  end
end
