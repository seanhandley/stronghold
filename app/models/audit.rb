class Audit < ActiveRecord::Base
  belongs_to :user, polymorphic: true
  belongs_to :auditable, polymorphic: true
  belongs_to :organization
  serialize :audited_changes

  after_save :try_to_set_organization

  # Take the serialized object hash '{'foo_id' => 1, 'bar_id' => 2}'
  # and return:
  #
  #   {
  #     'foo' => #<Foo id: 1, name: ...>,
  #     'bar' => #<Bar id: 1, name: ...>
  #   }
  def audited_objects
    Hash[audited_changes.map{|k,v| [extract_associated_object_type(k), extract_associated_object(k,v)] } ]
  end

  def self.for_organization_and_user(organization, user)
    Audit.where(user_id: user.id).where('organization_id is null').each(&:try_to_set_organization)
    where(organization_id: organization.id).includes(:user => :roles)
  end

  def try_to_set_organization
    if auditable_type == 'Organization'
      return if organization_id == auditable_id
      update_column(:organization_id, auditable_id) if auditable_id
    elsif auditable.respond_to?(:organization_id)
      return if organization_id == auditable.organization_id
      update_column(:organization_id, auditable.organization_id) if auditable.organization_id
    end
  end

  private

  def extract_associated_object(k,v)
    extract_associated_object_type(k).constantize.find_by_id(v)
  rescue NameError
    nil
  end

  def extract_associated_object_type(k)
    k.camelize.gsub('Id','')
  end

end