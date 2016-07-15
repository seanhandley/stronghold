class UserProjectRole < ActiveRecord::Base

  audited only: [:user_id, :project_id, :role_uuid]

  belongs_to :user
  belongs_to :project

  validates :role_uuid, presence: true

  after_save :create_project_role, on: :create
  after_destroy :destroy_project_role

  def self.required_role_ids
    ["heat_stack_owner", "_member_", "object-store"].collect do |name|
      os_roles.select{|r| r['name'].include? name}.collect{|r| r['id']}
    end.flatten.compact
  end

  private

  def create_project_role
    SyncUserProjectRolesJob.perform_later(true, *os_objects) unless Rails.env.test?
  end

  def destroy_project_role
    SyncUserProjectRolesJob.perform_later(false, *os_objects) unless Rails.env.test?
  end

  def os_objects
    [user.uuid, project.uuid, role_uuid]
  end

  def self.os_roles
    Rails.cache.fetch("required_project_roles", expires_in: 1.day) do
      OpenStackConnection.identity.list_roles.body['roles']
    end
  end

end
