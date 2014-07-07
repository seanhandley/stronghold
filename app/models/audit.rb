class Audit < ActiveRecord::Base
  belongs_to :user, polymorphic: true
  belongs_to :auditable, polymorphic: true
  belongs_to :organization
  serialize :audited_changes

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
    where(organization_id: nil).each do |audit|
      if audit.user
        audit.update_column(:organization_id, audit.user.organization_id)
      elsif organization_id = audit.audited_changes['organization_id']
        audit.update_column(:organization_id, organization_id)
      end
    end
    where(organization_id: organization.id)
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