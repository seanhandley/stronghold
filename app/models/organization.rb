class Organization < ActiveRecord::Base
  audited
  has_associated_audits

  after_save :generate_reference, :on => :create

  validates :name, length: {minimum: 1}, allow_blank: false
  validates :reference, :uniqueness => true

  has_many :users, dependent: :destroy
  has_many :roles, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :tenants, dependent: :destroy
  has_and_belongs_to_many :products

  belongs_to :primary_tenant, class_name: 'Tenant'

  def staff?
    (reference == STAFF_REFERENCE)
  end

  def colo?
    products.collect(&:name).include? 'Colocation'
  end

  private

  def generate_reference
    return nil if reference
    generate_reference_step(name.parameterize.gsub('-','').downcase.slice(0,18), 0)
  end

  def generate_reference_step(ref, count)
    new_ref = "#{ref}#{count == 0 ? '' : count }"
    if Organization.all.collect(&:reference).include?(new_ref)
      generate_reference_step(ref, (count+1))
    else
      update_column(:reference, new_ref)
      t = tenants.create name: "primary"
      update_column(:primary_tenant_id, t.id)
    end
  end

end