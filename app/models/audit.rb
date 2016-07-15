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

  def self.for_organization(organization)
    where(organization_id: organization.id).includes(:user => :roles)
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

  private

  def try_to_set_organization
    return if organization_id
    update_column(:organization_id, user&.organization_id)
  end

end