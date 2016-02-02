module OpenStack
  class User < OpenStackObject::User
    attributes :name, :email, :project_id, :enabled, :password

    def roles_for(project)
      service_method do |s|
        return s.list_roles_for_user_on_project(project.id, id).body['roles'].map{|u| Role.new(u)}
      end    
    end

    def self.update_password(uuid, password)
      unless Rails.env.test?
        conn = OpenStackConnection.identity
        u = conn.users.select {|u| u.id == uuid}.first
        u.update(password: password) if u
      end
    end

    def self.update_enabled(uuid, enabled)
      unless Rails.env.test?
        conn = OpenStackConnection.identity
        u = conn.users.select {|u| u.id == uuid}.first
        u.update(enabled: enabled) if u
      end    
    end
  end
end