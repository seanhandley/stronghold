module OpenStack
  class Project < OpenStackObject::Project
    attributes :name, :description, :enabled

    def users
      service_method do |s|
        return s.users(:project_id => id).map{|u| User.new(u)}
      end
    end

    def add_user(user, role)
      service_method do |s|
        return s.add_user_to_project(self.id, user.id, role.id)
      end
    end

    def remove_user(user, role)
      service_method do |s|
        return s.remove_user_from_project(self.id, user.id, role.id)
      end
    end

  end
end