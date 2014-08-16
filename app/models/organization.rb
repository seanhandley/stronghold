class Organization < ActiveRecord::Base
  audited
  has_associated_audits

  after_save :generate_reference, :on => :create

  validates :name, length: {minimum: 1}, allow_blank: false
  validates :reference, :uniqueness => true

  has_many :users
  has_many :roles
  has_many :invites

  tickets = nil

  def tickets
    if @tickets.nil?
      @tickets = Tickets.new(reference)
    end
    @tickets
  end

  private

  def generate_reference
    return nil if reference
    generate_reference_step(name.parameterize.gsub('-','').upcase.slice(0,8), 0)
    t = OpenStack::Tenant.create name: reference, enabled: true, description: "Customer: #{name}"
    update_column(:tenant_id, t.id)
  end

  def generate_reference_step(ref, count)
    new_ref = "#{ref}#{count == 0 ? '' : count }"
    if Organization.all.collect(&:reference).include?(new_ref)
      generate_reference_step(ref, (count+1))
    else
      update_column(:reference, new_ref)
    end
  end

end