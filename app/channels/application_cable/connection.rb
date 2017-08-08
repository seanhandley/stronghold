module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_organization_user
 
    def connect
      self.current_organization_user = find_verified_organization_user
    end
 
    private
      def find_verified_organization_user
        user_id         = cookies.signed[:user_id]
        organization_id = cookies.signed[:current_organization_id]
        if current_organization_user = OrganizationUser.find_by(user_id: user_id, organization_id: organization_id)
          current_organization_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
